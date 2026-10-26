// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MiniPool} from "../src/MiniPool.sol";
import {MockToken} from "../src/mocks/MockToken.sol";

contract MiniPoolTest is Test {
    MiniPool pool;
    MockToken tokenX;
    MockToken tokenY;

    address liquidityProvider = makeAddr("liquidityProvider");
    address alice = makeAddr("alice");
    address attacker = makeAddr("attacker");

    uint256 constant INITIAL_LIQUIDITY = 100e18;

    function setUp() public {
        tokenX = new MockToken("Token X", "TKX");
        tokenY = new MockToken("Token Y", "TKY");
        pool = new MiniPool(address(tokenX), address(tokenY));

        // Liquidity provider membuka pool dengan rasio 1:1
        tokenX.mint(liquidityProvider, INITIAL_LIQUIDITY);
        tokenY.mint(liquidityProvider, INITIAL_LIQUIDITY);
        vm.startPrank(liquidityProvider);
        tokenX.approve(address(pool), type(uint256).max);
        tokenY.approve(address(pool), type(uint256).max);
        pool.addLiquidity(INITIAL_LIQUIDITY, INITIAL_LIQUIDITY);
        vm.stopPrank();

        // Trader biasa dan penyerang punya modal masing-masing
        _fund(alice, 1_000e18);
        _fund(attacker, 1_000e18);
    }

    function _fund(address who, uint256 amount) internal {
        tokenX.mint(who, amount);
        tokenY.mint(who, amount);
        vm.startPrank(who);
        tokenX.approve(address(pool), type(uint256).max);
        tokenY.approve(address(pool), type(uint256).max);
        vm.stopPrank();
    }

    // TULIS TEST KAMU DI SINI
}
