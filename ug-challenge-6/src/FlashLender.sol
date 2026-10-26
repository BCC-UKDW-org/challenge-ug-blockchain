// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockToken} from "./mocks/MockToken.sol";

/// @notice Kontrak yang ingin meminjam lewat flash loan wajib mengimplementasikan interface ini.
interface IFlashLoanReceiver {
    /// @param amount    jumlah WETH yang dipinjam
    /// @param fee       fee yang wajib dibayar bersama pinjaman
    /// @param initiator alamat yang memanggil flashLoan
    /// @param data      data bebas yang diteruskan dari flashLoan
    function executeOperation(uint256 amount, uint256 fee, address initiator, bytes calldata data) external;
}

/// @title FlashLender
/// @notice Liquidity provider (LP) menyetor WETH dan mendapat shares. WETH di pool dipinjamkan
///         lewat flash loan dengan fee 0.3%. Fee menjadi milik LP, sehingga nilai setiap share naik.
/// @dev Aturan utama flash loan: pinjaman + fee WAJIB kembali dalam transaksi yang sama,
///      kalau tidak seluruh transaksi di-revert.
contract FlashLender {
    uint256 public constant FEE_BPS = 30; // 0.3%

    MockToken public immutable weth;

    /// @notice Total WETH milik LP (deposit + fee yang terkumpul - redeem).
    uint256 public totalAssets;
    uint256 public totalShares;
    mapping(address => uint256) public sharesOf;

    constructor(MockToken weth_) {
        weth = weth_;
    }

    /// @notice Setor WETH sebagai LP. Shares dihitung dari nilai share saat ini.
    function deposit(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "FlashLender: zero amount");
        shares = totalShares == 0 ? amount : amount * totalShares / totalAssets;
        require(shares > 0, "FlashLender: zero shares");

        sharesOf[msg.sender] += shares;
        totalShares += shares;
        totalAssets += amount;

        require(weth.transferFrom(msg.sender, address(this), amount), "FlashLender: transfer failed");
    }

    /// @notice Tukar shares kembali menjadi WETH (pokok + bagian fee).
    function redeem(uint256 shares) external returns (uint256 assets) {
        require(shares > 0, "FlashLender: zero shares");
        assets = shares * totalAssets / totalShares;

        sharesOf[msg.sender] -= shares;
        totalShares -= shares;
        totalAssets -= assets;

        require(weth.transfer(msg.sender, assets), "FlashLender: transfer failed");
    }

    /// @notice Pinjam WETH tanpa jaminan, asalkan pinjaman + fee kembali sebelum fungsi ini selesai.
    function flashLoan(address receiver, uint256 amount, bytes calldata data) external {
        uint256 balanceBefore = weth.balanceOf(address(this));
        require(amount > 0 && amount <= balanceBefore, "FlashLender: not enough liquidity");
        uint256 fee = getFee(amount);

        require(weth.transfer(receiver, amount), "FlashLender: transfer failed");
        IFlashLoanReceiver(receiver).executeOperation(amount, fee, msg.sender, data);

        require(weth.balanceOf(address(this)) >= balanceBefore + fee, "FlashLender: not repaid");
        totalAssets += fee;
    }

    function getFee(uint256 amount) public pure returns (uint256) {
        return amount * FEE_BPS / 10_000;
    }
}
