# Challenge 03 — Lucky Draw I

| | |
|---|---|
| **Level** | Intermediate |
| **Basis materi** | [Cyfrin Updraft — Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **Puppy Raffle** (reentrancy & mishandling of ETH) |
| **Tools** | Solidity, Foundry (Forge) |
| **Estimasi waktu** | Menonton materi ±2 jam + mengerjakan 60–120 menit |
| **Fokus** | Reentrancy yang benar-benar bisa dieksploitasi, kontrak penyerang, ETH yang dipaksa masuk (`selfdestruct`), menulis PoC & laporan |
| **Cek jawaban** | `./check.sh` (lihat [Cek mandiri](#️-cek-mandiri-dengan-checksh)) |

> ⚠️ **Sebelum mulai, baca [Aturan Utama](../README.md#️-aturan-utama--wajib-dibaca).**
> AI hanya boleh dipakai seperti Google, yaitu untuk mencari dokumentasi dan konsep. **Kode, penjelasan, dan laporan harus kamu tulis sendiri.**

---

## 🎯 Misi Kamu

Di [Challenge 01](../ug-challenge-1/) kamu sudah melihat bahwa `.call{value: ...}` **tidak otomatis rentan**: `SimpleVault` mengubah state sebelum mengirim ETH, sehingga reentrancy gagal. Sekarang giliran kontrak yang **benar-benar rentan**.

`LuckyDraw` adalah undian ETH sederhana:

- Pemain membeli tiket seharga `entranceFee` lewat `enter()`.
- Sebelum undian ditarik, pemain boleh membatalkan tiketnya lewat `refund()` dan mendapat uangnya kembali.
- Owner menarik pemenang lewat `drawWinner()`. Pemenang mendapat **80%** pot, sisanya **20%** menjadi fee.
- Pemenang mengambil hadiah lewat `claimPrize()`. Fee dikirim ke owner lewat `withdrawFees()`.

Developer mengklaim: *"Uang pemain aman. Refund hanya mengembalikan tiket milikmu sendiri, dan fee owner selalu bisa ditarik setelah undian selesai."*

**Tugasmu adalah membuktikan, dengan test, bahwa klaim itu salah.**

### Setelah menyelesaikan challenge ini, kamu akan bisa:

1. Melakukan **scoping & recon**: memetakan aktor, alur uang, dan asumsi developer.
2. Menulis **kontrak penyerang** yang mengeksploitasi reentrancy, lalu membuktikannya dengan PoC.
3. Menjelaskan mengapa **urutan** check → effect → interaction menentukan aman atau tidaknya sebuah fungsi.
4. Memahami bahwa **saldo ETH kontrak bisa berubah tanpa melewati fungsi apa pun**, dan mengapa `address(this).balance` berbahaya dijadikan dasar logika.
5. Menulis **finding** lengkap dengan dampak, PoC, dan rekomendasi perbaikan.

---

## 📺 Part 0 — Wajib Tonton Cyfrin Updraft Dulu

Challenge ini dibangun di atas section **Puppy Raffle** dari course [Smart Contract Security](https://updraft.cyfrin.io/courses/security). Tonton dulu materinya **sebelum** membuka soal.

### ✅ Wajib

- [ ] [Puppy Raffle Primer](https://updraft.cyfrin.io/courses/security/puppy-raffle/puppy-raffle-primer)
- [ ] [Phase 1: Scoping](https://updraft.cyfrin.io/courses/security/puppy-raffle/phase-1-scoping)
- [ ] [Recon: Reading Docs](https://updraft.cyfrin.io/courses/security/puppy-raffle/recon-reading-docs)
- [ ] ⭐ [Exploit: Reentrancy](https://updraft.cyfrin.io/courses/security/puppy-raffle/exploit-reentrancy)
- [ ] [Reentrancy: Remix Example](https://updraft.cyfrin.io/courses/security/puppy-raffle/reentrancy-remix-example)
- [ ] [Reentrancy: Mitigation](https://updraft.cyfrin.io/courses/security/puppy-raffle/reentrancy-mitigation)
- [ ] ⭐ [Reentrancy: PoC](https://updraft.cyfrin.io/courses/security/puppy-raffle/reentrancy-poc)
- [ ] ⭐ [Exploit: Mishandling Of ETH](https://updraft.cyfrin.io/courses/security/puppy-raffle/exploit-mishandling-of-eth)
- [ ] [Mishandling of ETH: Minimized](https://updraft.cyfrin.io/courses/security/puppy-raffle/mishandling-of-eth-minimized)
- [ ] [Case Study: Mishandling of ETH](https://updraft.cyfrin.io/courses/security/puppy-raffle/mishandling-of-eth-case-study)
- [ ] [Self Destruct and Review](https://updraft.cyfrin.io/courses/security/review/self-destruct)
- [ ] [Fallback and Receive](https://updraft.cyfrin.io/courses/security/review/fallback-and-receive)

### 🎮 Latihan pendamping (opsional)

- [Ethernaut](https://ethernaut.openzeppelin.com/): level **Re-entrancy** dan **Force**.
- Codebase asli yang diaudit di video: [Cyfrin/4-puppy-raffle-audit](https://github.com/Cyfrin/4-puppy-raffle-audit). Jangan menyalin laporan audit dari sana. Kontrak di challenge ini berbeda.

### 📖 Dokumentasi pendamping

| Topik | Sumber |
|---|---|
| Contoh reentrancy | [Solidity by Example — Re-Entrancy](https://solidity-by-example.org/hacks/re-entrancy/) |
| Contoh ETH paksa | [Solidity by Example — Self Destruct](https://solidity-by-example.org/hacks/self-destruct/) |
| Perilaku `selfdestruct` sekarang | [EIP-6780](https://eips.ethereum.org/EIPS/eip-6780), [Solidity Docs — Deactivate and Self-destruct](https://docs.soliditylang.org/en/latest/introduction-to-smart-contracts.html#deactivate-and-self-destruct) |
| Checks-Effects-Interactions | [Solidity Docs — Security Considerations](https://docs.soliditylang.org/en/latest/security-considerations.html) |
| `vm.expectRevert`, `vm.deal` | [Foundry Book — expectRevert](https://getfoundry.sh/reference/cheatcodes/expect-revert), [Foundry Book — deal](https://getfoundry.sh/reference/cheatcodes/deal) |

### ✅ Self-check sebelum mulai

- [ ] Kapan `receive()` sebuah kontrak dieksekusi?
- [ ] Mengapa `SimpleVault` di UG-1 **tidak** rentan reentrancy padahal memakai `.call`?
- [ ] Apa saja cara ETH bisa masuk ke sebuah kontrak **tanpa** memanggil fungsinya?
- [ ] Setelah EIP-6780, apa yang masih dilakukan `selfdestruct`, dan apa yang tidak lagi dilakukan?
- [ ] Apa beda **push payment** dan **pull payment**?

---

## 🧰 Setup

```bash
cd ug-challenge-3
forge build
```

Struktur folder:

```text
ug-challenge-3/
├── src/
│   └── LuckyDraw.sol        ← kontrak yang diaudit (JANGAN diubah)
├── test/
│   └── LuckyDraw.t.sol      ← kerangka test: tulis test-mu di sini
├── ANSWERS.md               ← jawaban & penjelasan per part
├── FINDINGS.md              ← laporan temuan (Part D)
├── check.sh                 ← cek mandiri
└── foundry.toml
```

Semua test ditulis di folder `test/`. Kontrak penyerang boleh ditulis di file yang sama atau di file baru, misalnya `test/Attacker.sol`.

```bash
forge test -vvv
```

### ✔️ Cek mandiri dengan `check.sh`

```bash
./check.sh B      # cek Part B saja
./check.sh        # cek semua part
```

**Cara kerjanya:** setiap PoC milikmu dijalankan terhadap kontrak asli dan terhadap beberapa versi `LuckyDraw` yang **masing-masing memperbaiki tepat satu bug**. PoC yang benar harus **lulus di kontrak asli** (bug terbukti ada) dan **gagal di versi yang bug-nya sudah diperbaiki** (PoC benar-benar menguji bug itu, bukan hal lain).

Contoh output:

```text
── Part B: Temuan #1 (refund)
   ✅ Semua PoC lulus di kontrak asli (bug terbukti ada)
   ❌ Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)
```

**Nama test wajib:**

| Part | Nama fungsi |
|---|---|
| B, C | diawali `test_PoC_`, contoh `test_PoC_NamaBugnya()`. Satu PoC per temuan. |

> ⚠️ `check.sh` hanya mengecek **kode**. Penjelasan di `ANSWERS.md` dan `FINDINGS.md` adalah bukti bahwa kamu paham, dan tim BCC UKDW bisa memintamu menjelaskannya kapan saja. Semua ✅ tetapi tidak bisa menjelaskan = belum lulus.
>
> Versi-versi kontrak pembanding disimpan dalam base64 di `.check-data` supaya tidak membocorkan jawaban. Men-decode-nya sebelum selesai sama saja dengan menyontek diri sendiri.
>
> Pengguna Windows: jalankan dari terminal **Ubuntu (WSL)**, lihat [panduan instalasi](../README.md#️-instalasi-cukup-sekali).

---

## 🔍 Kontrak yang Diaudit

| File | nSLOC | Scope |
|---|---|---|
| `src/LuckyDraw.sol` | ±80 | ✅ In scope |

**Aktor:**

| Aktor | Peran |
|---|---|
| Pemain | Membeli tiket (`enter`), boleh membatalkan tiket (`refund`), mengambil hadiah kalau menang (`claimPrize`). |
| Owner | Deployer kontrak. Menarik pemenang (`drawWinner`) dan menerima fee. **Dianggap dipercaya.** |
| Siapa saja | Boleh memanggil `withdrawFees()`. Fee selalu dikirim ke owner. |

File: [`src/LuckyDraw.sol`](./src/LuckyDraw.sol). Baca **NatSpec**-nya dengan teliti, karena di sanalah developer menuliskan perilaku yang **dimaksud**. Bug adalah penyimpangan antara yang dimaksud dan yang benar-benar terjadi.

```solidity
function refund(uint256 playerIndex) external {
    require(players[playerIndex] == msg.sender, "LuckyDraw: not your ticket");

    (bool success, ) = payable(msg.sender).call{value: entranceFee}("");
    require(success, "LuckyDraw: refund failed");

    players[playerIndex] = address(0);
    pot -= entranceFee;
    emit Refunded(msg.sender, playerIndex);
}

function withdrawFees() external {
    require(address(this).balance == totalFees + totalPendingPrize, "LuckyDraw: draw in progress");

    uint256 fees = totalFees;
    totalFees = 0;

    (bool success, ) = payable(owner).call{value: fees}("");
    require(success, "LuckyDraw: withdraw failed");
    emit FeesWithdrawn(fees);
}
```

**`check.sh` mengecek tepat 2 temuan.** Satu ada di sekitar `refund()`, satu lagi di sekitar `withdrawFees()`. Tugasmu adalah memahami **apa** masalahnya, **mengapa** itu masalah, dan **membuktikannya**.

### 🚫 Di luar scope (known issues)

Hal-hal berikut sudah diketahui dan **tidak** dicek oleh `check.sh`:

- Pemenang dipilih dari `seed` yang diberikan owner, jadi owner bisa memilih pemenang. Owner dianggap dipercaya. Masalah randomness dibahas di [Challenge 04](../ug-challenge-4/).
- Array `players` tidak dibatasi panjangnya, sehingga `delete players` makin mahal seiring jumlah pemain. Denial of Service dibahas di Challenge 04.
- Kalau owner adalah kontrak yang menolak ETH, `withdrawFees()` akan selalu revert. Ini tanggung jawab owner.
- `drawWinner()` menghitung tiket yang sudah di-refund saat mengecek minimal 2 tiket.

Kamu tetap boleh mencatat hal di atas di `FINDINGS.md` sebagai temuan Low/Informational.

---

## 🅰️ Part A — Scoping & Recon (tanpa kode)

Auditor tidak langsung menulis exploit. Pahami dulu protokolnya. Jawab di `ANSWERS.md`:

1. **Alur uang.** Gambarkan (ASCII atau tabel) ke mana ETH bergerak di setiap fungsi: `enter`, `refund`, `drawWinner`, `claimPrize`, `withdrawFees`.
2. **Tabel efek fungsi.** Untuk setiap fungsi, tulis variabel state apa yang berubah, kapan external call terjadi (sebelum atau sesudah perubahan state), dan siapa yang boleh memanggil.
3. **Pembukuan.** Dalam kondisi normal, `address(this).balance` seharusnya sama dengan penjumlahan variabel apa saja? Tulis persamaannya.
4. **Asumsi developer.** Tulis minimal 3 asumsi yang dibuat developer (contoh: "pemanggil `refund` adalah EOA"). Mana yang bisa dilanggar penyerang?

<details>
<summary>💡 Hint A-1 (arah)</summary>

Bandingkan urutan baris di `refund()` dengan `withdraw()` di `SimpleVault` (UG-1). Lalu lihat `withdrawFees()`: angka apa yang dibandingkan, dan siapa yang mengontrol angka tersebut?

</details>

---

## 🅱️ Part B — Bedah `refund()`

### Tugas B1 — Analisis

Jawab di `ANSWERS.md`:

1. Kalau pemanggil `refund()` adalah **kontrak**, kode apa yang dijalankan ketika ETH dikirim kepadanya?
2. Pada saat kode itu berjalan, apa nilai `players[playerIndex]`? Apakah `require` di baris pertama masih akan lolos?
3. Berapa ETH maksimal yang bisa diambil penyerang yang hanya membeli **satu** tiket?

### Tugas B2 — PoC

Tulis kontrak penyerang dan sebuah test `test_PoC_...` yang membuktikan penyerang bisa mengambil ETH **lebih dari** tiket yang ia beli.

Skenario yang disarankan: tiga pemain jujur membeli tiket, lalu penyerang membeli satu tiket dan menyerang. Assert kondisi akhirnya: berapa sisa ETH di `LuckyDraw`, dan berapa yang dimiliki penyerang?

<details>
<summary>💡 Hint B-1 (arah)</summary>

Penyerang perlu `receive()` yang memanggil `refund()` lagi dengan index yang sama. Kapan harus berhenti? Kalau terus memanggil padahal ETH di kontrak sudah habis, apa yang terjadi?

</details>

<details>
<summary>💡 Hint B-2 (konsep)</summary>

Tonton ulang [Reentrancy: PoC](https://updraft.cyfrin.io/courses/security/puppy-raffle/reentrancy-poc). Penyerang perlu tahu index tiketnya. Lihat fungsi view `getPlayersLength()`: tiket yang baru dibeli selalu berada di index terakhir.

</details>

<details>
<summary>💡 Hint B-3 (hampir jawaban)</summary>

Kontrak penyerang: simpan alamat raffle dan `entranceFee`; fungsi `attack()` (payable) memanggil `enter{value: fee}()`, mencatat `index = getPlayersLength() - 1`, lalu memanggil `refund(index)`. Di `receive()`: `if (address(raffle).balance >= fee) raffle.refund(index);`. Di test: setelah 3 pemain jujur masuk, panggil `attacker.attack{value: 1 ether}()`, lalu assert saldo raffle `0` dan saldo penyerang `4 ether`.

</details>

**✔️ Cek mandiri:** `./check.sh B`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅲 Part C — Bedah `withdrawFees()`

### Tugas C1 — Analisis

Jawab di `ANSWERS.md`:

1. `withdrawFees()` mengasumsikan `address(this).balance` **hanya** berubah lewat fungsi-fungsi `LuckyDraw`. Apakah asumsi itu benar? Sebutkan cara-cara ETH bisa masuk ke kontrak tanpa memanggil fungsinya (kontrak ini tidak punya `receive()`).
2. Apa yang terjadi pada fee owner kalau ada **1 wei** saja yang masuk dengan cara seperti itu? Apakah keadaan ini bisa dipulihkan?
3. Siapa yang mungkin melakukan ini, dan berapa biayanya bagi penyerang?

### Tugas C2 — PoC

Tulis test `test_PoC_...` yang membuktikan fee owner bisa **terkunci selamanya**. Jalankan satu undian sampai selesai (pemenang sudah claim), paksa ETH masuk, lalu tunjukkan bahwa `withdrawFees()` revert walaupun tidak ada undian yang berjalan.

> **Tentang `selfdestruct`:** sejak [EIP-6780](https://eips.ethereum.org/EIPS/eip-6780) (upgrade Cancun), `selfdestruct` tidak lagi menghapus kode kontrak (kecuali dipanggil pada transaksi yang sama dengan pembuatannya), **tetapi tetap mengirim seluruh ETH-nya ke alamat tujuan**, tanpa memanggil kode apa pun di alamat tersebut. Compiler akan memberi **warning** bahwa `selfdestruct` deprecated. Warning itu normal: kamu sedang mensimulasikan penyerang, bukan menulis kode produksi.
>
> `vm.deal(address(raffle), ...)` boleh dipakai untuk eksplorasi awal, tetapi PoC yang baik menunjukkan cara yang **bisa dilakukan penyerang sungguhan** di jaringan, yaitu lewat kontrak yang memanggil `selfdestruct`.

<details>
<summary>💡 Hint C-1 (arah)</summary>

Membuktikan "revert saat undian masih berjalan" **bukan** bug, karena itu memang perilaku yang dimaksud developer. Bug-nya adalah revert ketika undian **sudah selesai** dan seharusnya fee bisa ditarik.

</details>

<details>
<summary>💡 Hint C-2 (konsep)</summary>

Baca [Solidity by Example — Self Destruct](https://solidity-by-example.org/hacks/self-destruct/). Kontrak yang memanggil `selfdestruct(payable(target))` di dalam constructor-nya bisa dibuat dan "dibuang" dalam satu baris: `new NamaKontrak{value: ...}(target)`.

</details>

<details>
<summary>💡 Hint C-3 (hampir jawaban)</summary>

Alice dan Bob masuk, owner memanggil `drawWinner(0)` (Alice menang), Alice memanggil `claimPrize()`. Pada titik ini `withdrawFees()` *seharusnya bisa* berhasil (jangan dipanggil dulu, supaya `totalFees` tetap terisi). Lalu buat kontrak `ForceSender` yang constructor-nya `payable` dan berisi `selfdestruct(target)`, deploy dengan `{value: 1 wei}`. Setelah itu `vm.expectRevert("LuckyDraw: draw in progress")` sebelum `withdrawFees()`, dan assert `totalFees() > 0`.

</details>

**✔️ Cek mandiri:** `./check.sh C`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅳 Part D — Laporan Audit

Tulis **2 finding** di `FINDINGS.md` memakai template yang tersedia:

1. **Title** yang menjelaskan akar masalah **dan** dampaknya (contoh pola: *"Root cause di X menyebabkan Y"*).
2. **Severity** (Impact × Likelihood) beserta alasannya.
3. **Description** dengan potongan kode yang relevan.
4. **Impact**: siapa yang dirugikan dan seberapa besar.
5. **Proof of Concept**: langkah-langkah + kode test dari Part B/C + output.
6. **Recommended Mitigation** dalam bentuk `diff`.

Pertanyaan tambahan di `ANSWERS.md`:

- Untuk temuan `refund()`: sebutkan **dua** cara memperbaikinya, dan jelaskan kelebihan masing-masing.
- Untuk temuan `withdrawFees()`: kenapa memperbaikinya dengan `>=` (bukan `==`) masih kurang tepat? Apa sumber kebenaran yang lebih baik daripada `address(this).balance`?

<details>
<summary>💡 Hint D-1 (arah)</summary>

Tonton ulang [Reentrancy: Mitigation](https://updraft.cyfrin.io/courses/security/puppy-raffle/reentrancy-mitigation) (CEI dan reentrancy guard). Untuk `withdrawFees()`, pikirkan variabel internal apa yang sudah ada dan bisa menjawab pertanyaan "apakah undian sedang berjalan?".

</details>

---

## 🏁 Kriteria Keberhasilan

| Part | Kriteria | Bukti |
|---|---|---|
| A | Alur uang, efek fungsi, dan persamaan pembukuan dipetakan dengan benar. | `ANSWERS.md` |
| B | Reentrancy pada `refund()` dibuktikan dengan kontrak penyerang yang menguras ETH pemain lain. | `./check.sh B` ✅ + penjelasan |
| C | Fee yang terkunci karena ETH paksa dibuktikan dengan `selfdestruct`. | `./check.sh C` ✅ + penjelasan EIP-6780 |
| D | Dua finding ditulis lengkap dengan severity, PoC, dan mitigasi. | `FINDINGS.md` |

---

## 🚀 Mulai Sekarang

1. Tonton materi **Part 0** di Cyfrin Updraft.
2. Kerjakan **Part A** di `ANSWERS.md`.
3. Kerjakan **Part B**, lalu jalankan `./check.sh B`.
4. Semua ✅? Lanjut ke Part C dan D.

Target akhirnya: kamu bisa membedakan `.call` yang aman dan yang rentan hanya dengan membaca **urutan** kodenya, dan kamu tidak akan pernah lagi memakai `address(this).balance` sebagai sumber kebenaran pembukuan.
