// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {VaultProxy} from "../src/VaultProxy.sol";
import {StakingVaultV1} from "../src/StakingVaultV1.sol";
import {StakingVaultV2} from "../src/StakingVaultV2.sol";

contract StakingVaultTest is Test {
    StakingVaultV1 implementationV1;
    StakingVaultV2 implementationV2;
    VaultProxy proxy;

    /// @dev Proxy yang "dilihat" sebagai StakingVaultV1. Selalu berinteraksi lewat variabel ini, bukan lewat implementation.
    StakingVaultV1 vault;

    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Alur deploy sesuai dokumentasi: implementation -> proxy -> initialize lewat proxy.
        vm.startPrank(owner);
        implementationV1 = new StakingVaultV1();
        proxy = new VaultProxy(address(implementationV1));
        vault = StakingVaultV1(address(proxy));
        vault.initialize(owner);

        // Implementation V2 sudah di-deploy, tetapi BELUM dipakai (belum ada upgrade).
        implementationV2 = new StakingVaultV2();
        vm.stopPrank();

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(attacker, 1 ether);
    }

    // TULIS TEST KAMU DI SINI
}
