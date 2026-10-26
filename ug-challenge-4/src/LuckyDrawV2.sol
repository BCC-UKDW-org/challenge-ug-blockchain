// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LuckyDrawV2
/// @notice Undian berhadiah versi 2. Peserta membeli tiket dengan `entranceFee` per pemain.
///         Ketika undian ditarik, satu pemenang dipilih secara acak dan adil, mendapat 80% dari
///         total tiket, sedangkan 20% sisanya menjadi fee untuk owner.
/// @dev Perbaikan dari audit sebelumnya: hadiah memakai pola pull payment (`claimPrize`)
///      dan semua transfer ETH mengikuti Checks-Effects-Interactions.
contract LuckyDrawV2 {
    /// @notice Harga satu tiket (per pemain).
    uint256 public immutable entranceFee;
    /// @notice Penerima fee protokol.
    address public immutable owner;

    /// @notice Daftar pemain pada ronde yang sedang berjalan. Setiap alamat hanya boleh ikut satu kali per ronde.
    address[] public players;
    /// @notice Total fee yang terkumpul dan belum ditarik owner.
    uint64 public totalFees;
    /// @notice Pemenang ronde terakhir.
    address public lastWinner;
    /// @notice Hadiah yang bisa diklaim oleh setiap pemenang.
    mapping(address => uint256) public pendingPrize;

    event PlayersEntered(address[] newPlayers);
    event WinnerDrawn(address indexed winner, uint256 prize);
    event PrizeClaimed(address indexed winner, uint256 amount);
    event FeesWithdrawn(uint256 amount);

    constructor(uint256 _entranceFee) {
        entranceFee = _entranceFee;
        owner = msg.sender;
    }

    /// @notice Mendaftarkan satu atau lebih pemain sekaligus.
    /// @dev Pembayaran harus tepat `entranceFee * newPlayers.length`. Alamat duplikat ditolak.
    function enter(address[] calldata newPlayers) external payable {
        require(newPlayers.length > 0, "LuckyDraw: no players");
        require(msg.value == entranceFee * newPlayers.length, "LuckyDraw: wrong fee");

        for (uint256 i = 0; i < newPlayers.length; i++) {
            require(newPlayers[i] != address(0), "LuckyDraw: zero address");
            players.push(newPlayers[i]);
        }

        for (uint256 i = 0; i < players.length - 1; i++) {
            for (uint256 j = i + 1; j < players.length; j++) {
                require(players[i] != players[j], "LuckyDraw: duplicate player");
            }
        }

        emit PlayersEntered(newPlayers);
    }

    /// @notice Menarik pemenang secara acak dan adil. Siapa saja boleh memanggil.
    /// @dev Membutuhkan minimal 4 pemain. Pemenang mendapat 80% dari total tiket, owner 20%.
    function drawWinner() external {
        require(players.length >= 4, "LuckyDraw: need at least 4 players");

        uint256 winnerIndex =
            uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.prevrandao))) % players.length;
        address winner = players[winnerIndex];

        uint256 totalCollected = players.length * entranceFee;
        uint256 prize = (totalCollected * 80) / 100;
        uint256 fee = totalCollected - prize;

        totalFees = totalFees + uint64(fee);
        lastWinner = winner;
        pendingPrize[winner] += prize;
        delete players;

        emit WinnerDrawn(winner, prize);
    }

    /// @notice Pemenang mengambil hadiahnya.
    function claimPrize() external {
        uint256 amount = pendingPrize[msg.sender];
        require(amount > 0, "LuckyDraw: nothing to claim");

        pendingPrize[msg.sender] = 0;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "LuckyDraw: transfer failed");
        emit PrizeClaimed(msg.sender, amount);
    }

    /// @notice Owner menarik seluruh fee. Hanya bisa saat tidak ada ronde yang sedang berjalan.
    function withdrawFees() external {
        require(msg.sender == owner, "LuckyDraw: not owner");
        require(players.length == 0, "LuckyDraw: draw in progress");

        uint256 fees = totalFees;
        totalFees = 0;

        (bool success,) = payable(owner).call{value: fees}("");
        require(success, "LuckyDraw: transfer failed");
        emit FeesWithdrawn(fees);
    }

    /// @notice Jumlah pemain pada ronde yang sedang berjalan.
    function getPlayersCount() external view returns (uint256) {
        return players.length;
    }
}
