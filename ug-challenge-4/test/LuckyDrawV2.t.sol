// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {LuckyDrawV2} from "../src/LuckyDrawV2.sol";

contract LuckyDrawV2Test is Test {
    LuckyDrawV2 raffle;

    uint256 constant ENTRANCE_FEE = 1 ether;

    address owner = makeAddr("owner");
    address playerOne = makeAddr("playerOne");
    address playerTwo = makeAddr("playerTwo");
    address playerThree = makeAddr("playerThree");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        raffle = new LuckyDrawV2(ENTRANCE_FEE);

        vm.deal(playerOne, 1000 ether);
        vm.deal(playerTwo, 1000 ether);
        vm.deal(playerThree, 1000 ether);
        vm.deal(attacker, 1000 ether);
    }

    // TULIS TEST KAMU DI SINI
}
