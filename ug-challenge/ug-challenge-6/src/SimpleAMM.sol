// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockToken} from "./mocks/MockToken.sol";

/// @title SimpleAMM
/// @notice AMM constant product (x * y = k) untuk pasangan WETH/TOKEN dengan fee swap 0.3%.
/// @dev DI LUAR SCOPE AUDIT. Disederhanakan: likuiditas yang ditambahkan tidak bisa ditarik
///      kembali (tidak ada LP token). Reserve dibaca langsung dari saldo token milik AMM.
contract SimpleAMM {
    MockToken public immutable weth;
    MockToken public immutable token;

    constructor(MockToken weth_, MockToken token_) {
        weth = weth_;
        token = token_;
    }

    /// @notice Tambah likuiditas WETH dan TOKEN ke pool.
    function addLiquidity(uint256 wethAmount, uint256 tokenAmount) external {
        require(weth.transferFrom(msg.sender, address(this), wethAmount), "SimpleAMM: transfer failed");
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "SimpleAMM: transfer failed");
    }

    /// @notice Tukar WETH dengan TOKEN.
    function swapWethForToken(uint256 wethIn, uint256 minTokenOut) external returns (uint256 tokenOut) {
        tokenOut = getAmountOut(wethIn, weth.balanceOf(address(this)), token.balanceOf(address(this)));
        require(tokenOut >= minTokenOut, "SimpleAMM: slippage");
        require(weth.transferFrom(msg.sender, address(this), wethIn), "SimpleAMM: transfer failed");
        require(token.transfer(msg.sender, tokenOut), "SimpleAMM: transfer failed");
    }

    /// @notice Tukar TOKEN dengan WETH.
    function swapTokenForWeth(uint256 tokenIn, uint256 minWethOut) external returns (uint256 wethOut) {
        wethOut = getAmountOut(tokenIn, token.balanceOf(address(this)), weth.balanceOf(address(this)));
        require(wethOut >= minWethOut, "SimpleAMM: slippage");
        require(token.transferFrom(msg.sender, address(this), tokenIn), "SimpleAMM: transfer failed");
        require(weth.transfer(msg.sender, wethOut), "SimpleAMM: transfer failed");
    }

    /// @notice Harga 1 TOKEN dalam WETH (presisi 1e18), dihitung dari reserve saat ini.
    function getSpotPriceTokenInWeth() public view returns (uint256) {
        return weth.balanceOf(address(this)) * 1e18 / token.balanceOf(address(this));
    }

    /// @notice Rumus constant product dengan fee 0.3%.
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0, "SimpleAMM: invalid amount");
        uint256 amountInWithFee = amountIn * 997;
        return amountInWithFee * reserveOut / (reserveIn * 1000 + amountInWithFee);
    }
}
