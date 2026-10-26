// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title StakingVaultV1
/// @notice Vault tempat pengguna menitipkan (stake) ETH dan menariknya kembali kapan saja.
/// @dev Dipakai di belakang `VaultProxy`. Alur deploy:
///      1. Deploy `StakingVaultV1` (implementation).
///      2. Deploy `VaultProxy(implementation)`.
///      3. Panggil `initialize(owner)` lewat proxy.
///      Owner boleh meng-upgrade vault ke implementation baru lewat `upgradeTo`.
contract StakingVaultV1 {
    /// @dev Slot EIP-1967, sama dengan yang dipakai `VaultProxy`.
    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice Pemilik vault. Satu-satunya yang boleh meng-upgrade.
    address public owner;
    /// @notice Total ETH yang sedang di-stake.
    uint256 public totalStaked;
    /// @notice ETH yang di-stake oleh setiap pengguna.
    mapping(address => uint256) public stakes;

    event Initialized(address indexed owner);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Upgraded(address indexed implementation);

    modifier onlyOwner() {
        require(msg.sender == owner, "StakingVault: not owner");
        _;
    }

    /// @notice Menetapkan owner. Hanya boleh dipanggil SATU KALI, tepat setelah proxy di-deploy.
    /// @param owner_ Pemilik vault.
    function initialize(address owner_) external {
        owner = owner_;
        emit Initialized(owner_);
    }

    /// @notice Menitipkan ETH ke vault.
    function stake() external payable {
        require(msg.value > 0, "StakingVault: zero amount");
        stakes[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    /// @notice Menarik kembali ETH yang sudah di-stake.
    /// @param amount Jumlah ETH yang ditarik.
    function unstake(uint256 amount) external {
        require(amount > 0, "StakingVault: zero amount");
        require(stakes[msg.sender] >= amount, "StakingVault: insufficient stake");

        stakes[msg.sender] -= amount;
        totalStaked -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "StakingVault: transfer failed");
        emit Unstaked(msg.sender, amount);
    }

    /// @notice Mengganti implementation di belakang proxy. Hanya owner.
    /// @param newImplementation Alamat implementation baru.
    function upgradeTo(address newImplementation) external onlyOwner {
        require(newImplementation.code.length > 0, "StakingVault: not a contract");
        assembly {
            sstore(IMPLEMENTATION_SLOT, newImplementation)
        }
        emit Upgraded(newImplementation);
    }

    /// @notice Versi implementation.
    function version() external pure returns (string memory) {
        return "1";
    }
}
