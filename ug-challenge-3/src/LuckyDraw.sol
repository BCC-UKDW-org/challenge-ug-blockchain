// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LuckyDraw
/// @notice Undian ETH sederhana. Setiap pemain membeli tiket seharga `entranceFee`.
///         Saat undian ditarik, pemenang mendapat 80% pot dan 20% sisanya menjadi fee untuk owner.
/// @dev Alur: enter() -> (opsional) refund() -> drawWinner() -> claimPrize() & withdrawFees().
contract LuckyDraw {
    /// @notice Harga satu tiket.
    uint256 public immutable entranceFee;
    /// @notice Penerima fee. Owner juga satu-satunya yang boleh menarik undian.
    address public immutable owner;

    /// @notice Daftar tiket pada undian yang sedang berjalan. Tiket yang di-refund menjadi address(0).
    address[] public players;
    /// @notice Total ETH tiket aktif pada undian yang sedang berjalan.
    uint256 public pot;
    /// @notice Fee yang sudah terkumpul dan belum ditarik owner.
    uint256 public totalFees;
    /// @notice Hadiah yang sudah dimenangkan tetapi belum di-claim.
    mapping(address => uint256) public pendingPrize;
    /// @notice Total seluruh `pendingPrize`.
    uint256 public totalPendingPrize;

    event Entered(address indexed player);
    event Refunded(address indexed player, uint256 playerIndex);
    event WinnerDrawn(address indexed winner, uint256 prize, uint256 fee);
    event PrizeClaimed(address indexed winner, uint256 prize);
    event FeesWithdrawn(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "LuckyDraw: not owner");
        _;
    }

    constructor(uint256 entranceFee_) {
        require(entranceFee_ > 0, "LuckyDraw: fee must be > 0");
        entranceFee = entranceFee_;
        owner = msg.sender;
    }

    /// @notice Membeli satu tiket. Harus mengirim tepat `entranceFee`.
    function enter() external payable {
        require(msg.value == entranceFee, "LuckyDraw: wrong entrance fee");
        players.push(msg.sender);
        pot += msg.value;
        emit Entered(msg.sender);
    }

    /// @notice Membatalkan tiket sebelum undian ditarik dan mendapatkan kembali `entranceFee`.
    /// @dev Setiap tiket hanya bisa di-refund satu kali.
    /// @param playerIndex Posisi tiket milik pemanggil di array `players`.
    function refund(uint256 playerIndex) external {
        require(players[playerIndex] == msg.sender, "LuckyDraw: not your ticket");

        (bool success, ) = payable(msg.sender).call{value: entranceFee}("");
        require(success, "LuckyDraw: refund failed");

        players[playerIndex] = address(0);
        pot -= entranceFee;
        emit Refunded(msg.sender, playerIndex);
    }

    /// @notice Menarik pemenang undian. Hanya owner.
    /// @dev Pemilihan pemenang memakai `seed` dari owner (owner dipercaya, di luar scope challenge ini).
    function drawWinner(uint256 seed) external onlyOwner {
        require(players.length >= 2, "LuckyDraw: not enough players");
        address winner = players[seed % players.length];
        require(winner != address(0), "LuckyDraw: refunded ticket, use another seed");

        uint256 prize = (pot * 80) / 100;
        uint256 fee = pot - prize;

        totalFees += fee;
        pendingPrize[winner] += prize;
        totalPendingPrize += prize;

        delete players;
        pot = 0;
        emit WinnerDrawn(winner, prize, fee);
    }

    /// @notice Pemenang mengambil hadiahnya (pull payment).
    function claimPrize() external {
        uint256 prize = pendingPrize[msg.sender];
        require(prize > 0, "LuckyDraw: nothing to claim");

        pendingPrize[msg.sender] = 0;
        totalPendingPrize -= prize;

        (bool success, ) = payable(msg.sender).call{value: prize}("");
        require(success, "LuckyDraw: claim failed");
        emit PrizeClaimed(msg.sender, prize);
    }

    /// @notice Mengirim seluruh fee yang terkumpul ke owner. Boleh dipanggil siapa saja.
    /// @dev Fee hanya boleh ditarik ketika tidak ada undian yang sedang berjalan,
    ///      yaitu ketika seluruh ETH di kontrak hanyalah fee + hadiah yang belum di-claim.
    function withdrawFees() external {
        require(address(this).balance == totalFees + totalPendingPrize, "LuckyDraw: draw in progress");

        uint256 fees = totalFees;
        totalFees = 0;

        (bool success, ) = payable(owner).call{value: fees}("");
        require(success, "LuckyDraw: withdraw failed");
        emit FeesWithdrawn(fees);
    }

    /// @notice Jumlah tiket (termasuk tiket yang sudah di-refund) pada undian yang sedang berjalan.
    function getPlayersLength() external view returns (uint256) {
        return players.length;
    }
}
