// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

/// @title MiniPool
/// @notice AMM constant product (x * y = k) untuk sepasang token, terinspirasi Uniswap V2.
/// @dev Reserve selalu dibaca dari saldo token milik pool. Fee swap 0.3% tetap tinggal di pool
///      dan menjadi keuntungan liquidity provider, sehingga x * y TIDAK PERNAH TURUN akibat swap.
contract MiniPool {
    error MiniPool__InvalidToken();
    error MiniPool__ZeroAmount();
    error MiniPool__DeadlinePassed();
    error MiniPool__SlippageExceeded();
    error MiniPool__InsufficientLiquidity();
    error MiniPool__TransferFailed();

    event LiquidityAdded(address indexed provider, uint256 amountX, uint256 amountY, uint256 shares);
    event LiquidityRemoved(address indexed provider, uint256 amountX, uint256 amountY, uint256 shares);
    event Swap(address indexed trader, address indexed tokenIn, uint256 amountIn, uint256 amountOut);

    /// @notice Deposit pertama minimal sebesar ini untuk tiap token.
    uint256 public constant MINIMUM_INITIAL_DEPOSIT = 1e15;
    /// @notice Insentif untuk trader aktif: setiap swap ke-10 mendapat bonus 1 token.
    uint256 public constant SWAP_INCENTIVE_INTERVAL = 10;
    uint256 public constant SWAP_INCENTIVE = 1e18;

    IERC20 public immutable tokenX;
    IERC20 public immutable tokenY;

    uint256 public totalShares;
    mapping(address => uint256) public shares;
    uint256 public swapCount;

    constructor(address tokenX_, address tokenY_) {
        if (tokenX_ == address(0) || tokenY_ == address(0) || tokenX_ == tokenY_) revert MiniPool__InvalidToken();
        tokenX = IERC20(tokenX_);
        tokenY = IERC20(tokenY_);
    }

    /// @notice Menambah likuiditas. Kirim kedua token sesuai rasio reserve saat ini;
    ///         kelebihan dari rasio tersebut menjadi milik pool.
    /// @return minted Jumlah share yang diterima liquidity provider.
    function addLiquidity(uint256 amountX, uint256 amountY) external returns (uint256 minted) {
        if (amountX == 0 || amountY == 0) revert MiniPool__ZeroAmount();

        if (totalShares == 0) {
            if (amountX < MINIMUM_INITIAL_DEPOSIT || amountY < MINIMUM_INITIAL_DEPOSIT) {
                revert MiniPool__InsufficientLiquidity();
            }
            minted = amountX;
        } else {
            uint256 byX = (amountX * totalShares) / tokenX.balanceOf(address(this));
            uint256 byY = (amountY * totalShares) / tokenY.balanceOf(address(this));
            minted = byX < byY ? byX : byY;
            if (minted == 0) revert MiniPool__ZeroAmount();
        }

        shares[msg.sender] += minted;
        totalShares += minted;

        _pull(tokenX, amountX);
        _pull(tokenY, amountY);
        emit LiquidityAdded(msg.sender, amountX, amountY, minted);
    }

    /// @notice Menarik likuiditas secara proporsional terhadap share yang dibakar.
    function removeLiquidity(uint256 shareAmount) external returns (uint256 amountX, uint256 amountY) {
        if (shareAmount == 0) revert MiniPool__ZeroAmount();

        amountX = (shareAmount * tokenX.balanceOf(address(this))) / totalShares;
        amountY = (shareAmount * tokenY.balanceOf(address(this))) / totalShares;

        shares[msg.sender] -= shareAmount;
        totalShares -= shareAmount;

        _push(tokenX, amountX);
        _push(tokenY, amountY);
        emit LiquidityRemoved(msg.sender, amountX, amountY, shareAmount);
    }

    /// @notice Jumlah output untuk input tertentu, setelah fee 0.3%.
    function getOutputAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve)
        public
        pure
        returns (uint256)
    {
        uint256 inputWithFee = inputAmount * 997;
        return (inputWithFee * outputReserve) / (inputReserve * 1000 + inputWithFee);
    }

    /// @notice Jumlah input yang dibutuhkan untuk output tertentu, setelah fee 0.3%.
    function getInputAmount(uint256 outputAmount, uint256 inputReserve, uint256 outputReserve)
        public
        pure
        returns (uint256)
    {
        if (outputAmount >= outputReserve) revert MiniPool__InsufficientLiquidity();
        return (inputReserve * outputAmount * 10000) / ((outputReserve - outputAmount) * 997) + 1;
    }

    /// @notice Menukar `amountIn` token masuk dengan output sebanyak mungkin.
    /// @param minAmountOut Output minimum; transaksi revert kalau output lebih kecil (slippage protection).
    /// @param deadline Transaksi revert kalau dieksekusi setelah waktu ini.
    function swapExactInput(address tokenIn, uint256 amountIn, uint256 minAmountOut, uint64 deadline)
        external
        returns (uint256 amountOut)
    {
        if (block.timestamp > deadline) revert MiniPool__DeadlinePassed();
        if (amountIn == 0) revert MiniPool__ZeroAmount();

        (IERC20 inToken, IERC20 outToken) = _pair(tokenIn);
        amountOut = getOutputAmount(amountIn, inToken.balanceOf(address(this)), outToken.balanceOf(address(this)));
        if (amountOut < minAmountOut) revert MiniPool__SlippageExceeded();

        _swap(inToken, outToken, amountIn, amountOut);
    }

    /// @notice Menukar token masuk untuk mendapatkan tepat `amountOut` token keluar.
    /// @param maxAmountIn Input maksimum; transaksi revert kalau input lebih besar (slippage protection).
    /// @param deadline Transaksi revert kalau dieksekusi setelah waktu ini.
    function swapExactOutput(address tokenIn, uint256 amountOut, uint256 maxAmountIn, uint64 deadline)
        external
        returns (uint256 amountIn)
    {
        if (amountOut == 0) revert MiniPool__ZeroAmount();

        (IERC20 inToken, IERC20 outToken) = _pair(tokenIn);
        amountIn = getInputAmount(amountOut, inToken.balanceOf(address(this)), outToken.balanceOf(address(this)));

        _swap(inToken, outToken, amountIn, amountOut);
    }

    function _swap(IERC20 inToken, IERC20 outToken, uint256 amountIn, uint256 amountOut) internal {
        swapCount++;
        if (swapCount % SWAP_INCENTIVE_INTERVAL == 0) {
            _push(outToken, SWAP_INCENTIVE);
        }

        _pull(inToken, amountIn);
        _push(outToken, amountOut);
        emit Swap(msg.sender, address(inToken), amountIn, amountOut);
    }

    function _pair(address tokenIn) internal view returns (IERC20, IERC20) {
        if (tokenIn == address(tokenX)) return (tokenX, tokenY);
        if (tokenIn == address(tokenY)) return (tokenY, tokenX);
        revert MiniPool__InvalidToken();
    }

    function _pull(IERC20 token, uint256 amount) internal {
        if (!token.transferFrom(msg.sender, address(this), amount)) revert MiniPool__TransferFailed();
    }

    function _push(IERC20 token, uint256 amount) internal {
        if (!token.transfer(msg.sender, amount)) revert MiniPool__TransferFailed();
    }
}
