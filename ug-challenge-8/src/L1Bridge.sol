// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockToken} from "./mocks/MockToken.sol";
import {BridgeVault} from "./BridgeVault.sol";

/// @title L1Bridge
/// @notice Jembatan token dari L1 ke L2 dan sebaliknya.
///
///         L1 → L2: pengguna memanggil `depositTokensToL2`. Token dikunci di `BridgeVault`, lalu
///         operator off-chain membaca event `Deposit` dan mencetak token yang sama untuk
///         `l2Recipient` di L2.
///
///         L2 → L1: pengguna membakar token di L2. Setelah memverifikasinya, `signer` menandatangani
///         pesan penarikan (`to`, `amount`). Pengguna mengirim tanda tangan itu ke
///         `withdrawTokensToL1` untuk menerima token dari vault.
/// @dev Klaim developer:
///      1. Hanya pemilik token yang bisa mendepositkan token miliknya ke L2.
///      2. Setiap tanda tangan signer hanya berlaku untuk SATU kali penarikan.
contract L1Bridge {
    MockToken public immutable token;
    BridgeVault public immutable vault;
    address public immutable signer;

    event Deposit(address indexed from, address indexed l2Recipient, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);

    constructor(MockToken token_, address signer_) {
        require(signer_ != address(0), "L1Bridge: zero signer");
        token = token_;
        signer = signer_;
        vault = new BridgeVault(token_);
    }

    /// @notice Mengunci token di vault untuk dicetak ulang di L2.
    /// @param from Pemilik token. Harus sudah `approve` bridge.
    /// @param l2Recipient Penerima token di L2.
    /// @param amount Jumlah token.
    function depositTokensToL2(address from, address l2Recipient, uint256 amount) external {
        require(amount > 0, "L1Bridge: zero amount");
        require(token.transferFrom(from, address(vault), amount), "L1Bridge: transfer failed");
        emit Deposit(from, l2Recipient, amount);
    }

    /// @notice Menarik token dari vault dengan tanda tangan `signer`.
    /// @dev Setiap tanda tangan hanya untuk SATU kali penarikan.
    /// @param to Penerima token di L1.
    /// @param amount Jumlah token.
    function withdrawTokensToL1(address to, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 digest = getWithdrawalDigest(to, amount);
        address recovered = ecrecover(digest, v, r, s);
        require(recovered != address(0) && recovered == signer, "L1Bridge: invalid signature");

        require(token.transferFrom(address(vault), to, amount), "L1Bridge: transfer failed");
        emit Withdrawal(to, amount);
    }

    /// @notice Digest yang harus ditandatangani `signer` untuk sebuah penarikan (format EIP-191).
    function getWithdrawalDigest(address to, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encode(to, amount))));
    }
}
