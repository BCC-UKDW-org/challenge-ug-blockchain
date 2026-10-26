// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MockToken} from "../src/mocks/MockToken.sol";
import {SimpleAMM} from "../src/SimpleAMM.sol";
import {FlashLender, IFlashLoanReceiver} from "../src/FlashLender.sol";
import {CollateralLoan} from "../src/CollateralLoan.sol";

contract FlashLenderTest is Test {
    MockToken weth;
    MockToken token;
    SimpleAMM amm;
    FlashLender lender;
    CollateralLoan loan;

    address lp = makeAddr("lp");
    address treasury = makeAddr("treasury");
    address attacker = makeAddr("attacker");

    function setUp() public {
        weth = new MockToken("Wrapped Ether", "WETH");
        token = new MockToken("Token", "TKN");

        // AMM: 100 WETH : 10_000 TKN  ->  harga awal 1 TKN = 0.01 WETH
        amm = new SimpleAMM(weth, token);
        weth.mint(address(this), 100 ether);
        token.mint(address(this), 10_000 ether);
        weth.approve(address(amm), type(uint256).max);
        token.approve(address(amm), type(uint256).max);
        amm.addLiquidity(100 ether, 10_000 ether);

        // FlashLender: LP menyetor 1_000 WETH
        lender = new FlashLender(weth);
        weth.mint(lp, 1_000 ether);
        vm.startPrank(lp);
        weth.approve(address(lender), type(uint256).max);
        lender.deposit(1_000 ether);
        vm.stopPrank();

        // CollateralLoan: treasury menyediakan 500 WETH untuk dipinjamkan
        loan = new CollateralLoan(weth, token, amm);
        weth.mint(treasury, 500 ether);
        vm.prank(treasury);
        weth.transfer(address(loan), 500 ether);

        // Modal awal penyerang
        weth.mint(attacker, 10 ether);
        token.mint(attacker, 1_000 ether);
    }

    // TULIS TEST KAMU DI SINI
}
