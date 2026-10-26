// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title StakingVaultV2
/// @notice Versi baru `StakingVaultV1`. Fitur baru: owner bisa menetapkan biaya penarikan (withdrawal fee)
///         maksimal 5%. Semua stake dari V1 tetap utuh setelah upgrade.
/// @dev Di-deploy sebagai implementation baru, lalu owner memanggil `upgradeTo(V2)` lewat proxy.
contract StakingVaultV2 {
    /// @dev Slot EIP-1967, sama dengan yang dipakai `VaultProxy`.
    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice Biaya maksimal: 500 bps = 5%.
    uint256 public constant MAX_FEE_BPS = 500;

    /// @notice Biaya penarikan dalam basis point (1 bps = 0,01%). Fitur baru di V2.
    uint256 public withdrawalFeeBps;
    /// @notice Pemilik vault. Satu-satunya yang boleh meng-upgrade dan mengatur fee.
    address public owner;
    /// @notice Total ETH yang sedang di-stake.
    uint256 public totalStaked;
    /// @notice ETH yang di-stake oleh setiap pengguna.
    mapping(address => uint256) public stakes;

    event Initialized(address indexed owner);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Upgraded(address indexed implementation);
    event WithdrawalFeeUpdated(uint256 feeBps);

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

    /// @notice Menarik kembali ETH yang sudah di-stake, dipotong `withdrawalFeeBps` untuk owner.
    /// @param amount Jumlah stake yang ditarik (sebelum dipotong fee).
    function unstake(uint256 amount) external {
        require(amount > 0, "StakingVault: zero amount");
        require(stakes[msg.sender] >= amount, "StakingVault: insufficient stake");

        uint256 fee = (amount * withdrawalFeeBps) / 10_000;
        stakes[msg.sender] -= amount;
        totalStaked -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount - fee}("");
        require(success, "StakingVault: transfer failed");
        if (fee > 0) {
            (bool feeSuccess, ) = payable(owner).call{value: fee}("");
            require(feeSuccess, "StakingVault: fee transfer failed");
        }
        emit Unstaked(msg.sender, amount);
    }

    /// @notice Mengatur biaya penarikan. Hanya owner, maksimal `MAX_FEE_BPS`.
    /// @param feeBps Biaya baru dalam basis point.
    function setWithdrawalFee(uint256 feeBps) external onlyOwner {
        require(feeBps <= MAX_FEE_BPS, "StakingVault: fee too high");
        withdrawalFeeBps = feeBps;
        emit WithdrawalFeeUpdated(feeBps);
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
        return "2";
    }
}
