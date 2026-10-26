// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MockToken} from "../src/mocks/MockToken.sol";
import {BridgeVault} from "../src/BridgeVault.sol";
import {L1Bridge} from "../src/L1Bridge.sol";

contract L1BridgeTest is Test {
    MockToken token;
    L1Bridge bridge;
    BridgeVault vault;

    /// @dev Kunci privat signer dipakai untuk menandatangani penarikan dengan vm.sign.
    address signer;
    uint256 signerKey;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address attacker = makeAddr("attacker");

    function setUp() public {
        (signer, signerKey) = makeAddrAndKey("signer");

        token = new MockToken("Bridge Token", "BRG");
        bridge = new L1Bridge(token, signer);
        vault = bridge.vault();

        token.mint(alice, 100e18);
        token.mint(bob, 100e18);
        token.mint(attacker, 1e18);

        // Banyak dApp meminta approve "tak terbatas" supaya pengguna tidak perlu approve berulang kali.
        vm.prank(alice);
        token.approve(address(bridge), type(uint256).max);
        vm.prank(bob);
        token.approve(address(bridge), type(uint256).max);
    }

    // TULIS TEST KAMU DI SINI
}
