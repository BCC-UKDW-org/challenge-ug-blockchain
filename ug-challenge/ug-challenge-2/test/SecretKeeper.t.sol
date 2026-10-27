// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SecretKeeper} from "../src/SecretKeeper.sol";

contract SecretKeeperTest is Test {
    SecretKeeper keeper;

    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    string constant OWNER_SECRET = "rahasia123";

    function setUp() public {
        vm.prank(owner);
        keeper = new SecretKeeper();

        vm.prank(owner);
        keeper.setSecret(OWNER_SECRET);
    }

    // TULIS TEST KAMU DI SINI
}
