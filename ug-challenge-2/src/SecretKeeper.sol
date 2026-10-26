// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecretKeeper
/// @notice Brankas sederhana untuk menyimpan satu secret milik owner, misalnya PIN atau kata sandi.
/// @dev Klaim developer:
///      1. Hanya owner yang boleh mengganti secret.
///      2. Hanya owner yang bisa melihat secret.
contract SecretKeeper {
    error SecretKeeper__NotOwner();

    address private s_owner;
    string private s_secret;

    event SecretUpdated();

    constructor() {
        s_owner = msg.sender;
    }

    /// @notice Mengganti secret. Hanya owner yang boleh memanggil fungsi ini.
    /// @param newSecret Secret baru.
    function setSecret(string calldata newSecret) external {
        s_secret = newSecret;
        emit SecretUpdated();
    }

    /// @notice Mengembalikan secret. Hanya owner yang boleh memanggil fungsi ini.
    /// @return Secret yang tersimpan.
    function getSecret() external view returns (string memory) {
        if (msg.sender != s_owner) revert SecretKeeper__NotOwner();
        return s_secret;
    }
}
