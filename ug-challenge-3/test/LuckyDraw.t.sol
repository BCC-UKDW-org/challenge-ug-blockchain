// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {LuckyDraw} from "../src/LuckyDraw.sol";

contract LuckyDrawTest is Test {
    LuckyDraw raffle;

    uint256 constant ENTRANCE_FEE = 1 ether;

    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");

    function setUp() public {
        vm.prank(owner);
        raffle = new LuckyDraw(ENTRANCE_FEE);

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(carol, 10 ether);
    }

    // TULIS TEST KAMU DI SINI
}
