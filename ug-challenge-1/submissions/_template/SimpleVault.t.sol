// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleVault} from "../../src/SimpleVault.sol";

contract SimpleVaultTest is Test {
    SimpleVault vault;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        vault = new SimpleVault();

        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    // TULIS TEST KAMU DI SINI
}
