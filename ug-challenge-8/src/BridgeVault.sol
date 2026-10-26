// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockToken} from "./mocks/MockToken.sol";

/// @title BridgeVault
/// @notice Tempat token L1 dikunci selama token tersebut "berada" di L2.
/// @dev Di-deploy oleh `L1Bridge`. Vault memberi bridge izin tak terbatas (`approve`) supaya
///      bridge bisa mengeluarkan token saat ada penarikan yang sah.
contract BridgeVault {
    MockToken public immutable token;
    address public immutable bridge;

    constructor(MockToken token_) {
        token = token_;
        bridge = msg.sender;
        token_.approve(msg.sender, type(uint256).max);
    }
}
