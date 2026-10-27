# Challenge 06 — Flash Lender

| | |
|---|---|
| **Level** | Intermediate → Advanced |
| **Basis materi** | [Cyfrin Updraft — Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **Thunder Loan** (flash loan & oracle manipulation) |
| **Tools** | Solidity, Foundry (Forge) |
| **Estimasi waktu** | Menonton materi ±3 jam + mengerjakan 60–120 menit per part |
| **Fokus** | Flash loan, akuntansi liquidity provider, manipulasi harga/oracle, menulis PoC dengan kontrak penyerang |
| **Cek jawaban** | `./check.sh` (lihat [Cek mandiri](#️-cek-mandiri-dengan-checksh)) |

> ⚠️ **Sebelum mulai, baca [Aturan Utama](../../README.md#️-aturan-utama--wajib-dibaca).**
> AI hanya boleh dipakai seperti Google, yaitu untuk mencari dokumentasi dan konsep. **Kode, penjelasan, dan laporan harus kamu tulis sendiri.**

---

## 🎯 Misi Kamu

Sebuah tim DeFi meluncurkan dua produk sekaligus:

1. **FlashLender**: liquidity provider (LP) menyetor WETH, lalu siapa pun bisa meminjam WETH itu **tanpa jaminan** lewat *flash loan*, asalkan pinjaman dan fee 0.3% kembali dalam transaksi yang sama. Fee menjadi keuntungan LP.
2. **CollateralLoan**: pengguna menjaminkan TKN untuk meminjam WETH, maksimal 50% dari nilai jaminannya. Harga TKN diambil dari sebuah AMM.

Developer mengklaim:

> *"Flash loan kami aman karena kami selalu mengecek bahwa dana sudah kembali sebelum transaksi selesai. Pinjaman kami juga aman karena harga jaminan diambil langsung dari pasar (AMM), jadi selalu up-to-date."*

**Tugasmu adalah membuktikan, dengan test, apakah kedua klaim itu benar.**

### Setelah menyelesaikan challenge ini, kamu akan bisa:

1. Menjelaskan cara kerja **flash loan** dan mengapa pinjaman tanpa jaminan bisa aman.
2. Menulis **kontrak penerima flash loan** (receiver) di Foundry, baik yang jujur maupun yang menyerang.
3. Menemukan celah ketika sebuah protokol **mengecek saldo** alih-alih mengecek **cara** dana dikembalikan.
4. Menjelaskan mengapa **harga spot AMM** tidak boleh dipakai sebagai oracle, dan membuktikannya dengan PoC.
5. Merangkai beberapa protokol (flash loan → AMM → lending) menjadi satu serangan.

---

## 📺 Part 0 — Wajib Tonton Cyfrin Updraft Dulu

Challenge ini dibangun di atas materi **Cyfrin Updraft**. Tonton dulu materinya **sebelum** membuka soal. Konsep flash loan dan oracle manipulation sulit dipahami hanya dari membaca kode.

### ✅ Wajib (semua peserta)

Section **Thunder Loan** dari course [Smart Contract Security](https://updraft.cyfrin.io/courses/security):

- [ ] [Introduction](https://updraft.cyfrin.io/courses/security/thunder-loan/introduction)
- [ ] [Reading the Docs](https://updraft.cyfrin.io/courses/security/thunder-loan/reading-the-docs)
- [ ] ⭐ [What is a Flash Loan?](https://updraft.cyfrin.io/courses/security/thunder-loan/what-is-flash-loan)
- [ ] [Pay Back or Revert](https://updraft.cyfrin.io/courses/security/thunder-loan/pay-back-or-revert)
- [ ] [Liquidity Providers](https://updraft.cyfrin.io/courses/security/thunder-loan/liquidity-providers)
- [ ] [Arbitrage Walkthrough](https://updraft.cyfrin.io/courses/security/thunder-loan/arbitrage-walkthrough)
- [ ] [Are Flash Loans Bad?](https://updraft.cyfrin.io/courses/security/thunder-loan/are-flash-loans-bad)
- [ ] [Improving Test Coverage to Find a High](https://updraft.cyfrin.io/courses/security/thunder-loan/improving-test-coverage-to-find-a-high)
- [ ] ⭐ [Exploit: Oracle Manipulation](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-oracle-manipulation-intro)
- [ ] [Oracle Manipulation: Minimized](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-oracle-manipulation-minimized)
- [ ] [Oracle Manipulation: ThunderLoan PoC](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-oracle-manipulation-thunderloan-poc)
- [ ] [Oracle Manipulation: Recap](https://updraft.cyfrin.io/courses/security/thunder-loan/oracle-manipulation-recap)
- [ ] ⭐ [Exploit: Deposit Instead Of Repay](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-deposit-instead-of-repay)

Belum paham cara kerja AMM? Tonton dulu [How AMMs Work](https://updraft.cyfrin.io/courses/security/tswap/how-amms-work) dari section TSwap (materi Challenge 05).

### 🎮 Latihan pendamping (opsional)

[Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/) punya level yang konsepnya mirip. Kerjakan **setelah** challenge ini selesai supaya tidak tergoda mencontek pola solusinya:

- [Unstoppable](https://www.damnvulnerabledefi.xyz/challenges/unstoppable/): flash loan yang bisa dibuat macet
- [Side Entrance](https://www.damnvulnerabledefi.xyz/challenges/side-entrance/): flash loan dan fungsi deposit
- [Puppet](https://www.damnvulnerabledefi.xyz/challenges/puppet/): lending dengan harga dari AMM

### 📖 Dokumentasi pendamping

| Topik | Sumber |
|---|---|
| Standar flash loan | [EIP-3156: Flash Loans](https://eips.ethereum.org/EIPS/eip-3156) |
| Oracle berbasis TWAP | [Uniswap V2 — Oracles](https://docs.uniswap.org/contracts/v2/concepts/core-concepts/oracles) |
| Oracle terdesentralisasi | [Chainlink Data Feeds](https://docs.chain.link/data-feeds) |
| Mengharapkan revert | [Foundry Book — `expectRevert`](https://getfoundry.sh/reference/cheatcodes/expect-revert) |
| Studi kasus nyata | [Solodit](https://solodit.cyfrin.io/), cari "oracle manipulation" atau "flash loan" |
| Codebase asli di course | [Cyfrin/6-thunder-loan-audit](https://github.com/Cyfrin/6-thunder-loan-audit) |

### ✅ Self-check sebelum mulai

Jawab di kepalamu. Kalau ada lebih dari dua yang belum bisa kamu jawab, tonton ulang materinya.

- [ ] Kenapa flash loan tidak butuh jaminan? Apa yang terjadi kalau peminjam tidak mengembalikan dana?
- [ ] Siapa yang mendapat fee flash loan, dan bagaimana nilai share LP bertambah?
- [ ] Apa beda **harga spot** dan **TWAP**?
- [ ] Kalau kamu membeli banyak TKN dari AMM dalam satu swap, apa yang terjadi pada harga TKN di AMM itu?
- [ ] Kenapa serangan flash loan biasanya membutuhkan **kontrak** penyerang, bukan sekadar EOA?

---

## 🧰 Setup

Proyek Foundry sudah disiapkan, jadi kamu **tidak perlu** menjalankan `forge init`.

```bash
cd ug-challenge/ug-challenge-6   # dari folder utama repo
forge build
```

Struktur folder:

```text
ug-challenge-6/
├── src/
│   ├── FlashLender.sol        ← diaudit
│   ├── CollateralLoan.sol     ← diaudit
│   ├── SimpleAMM.sol          ← di luar scope (dianggap benar)
│   └── mocks/MockToken.sol    ← di luar scope
├── test/
│   └── FlashLender.t.sol      ← kerangka test: tulis test-mu di sini
├── ANSWERS.md                 ← penjelasan & jawaban per part
├── FINDINGS.md                ← laporan bug (Part D)
├── check.sh                   ← cek mandiri
└── foundry.toml
```

Semua test ditulis di folder `test/`. Kerangka `setUp()` sudah menyiapkan semua kontrak dan aktor:

| Aktor / kontrak | Kondisi awal |
|---|---|
| `amm` | 100 WETH : 10.000 TKN, sehingga harga awal 1 TKN = 0.01 WETH |
| `lender` | `lp` sudah menyetor 1.000 WETH |
| `loan` | `treasury` sudah mengisi 500 WETH untuk dipinjamkan |
| `attacker` | punya 10 WETH dan 1.000 TKN |

Kamu boleh menambah kontrak pembantu, misalnya receiver atau kontrak penyerang, di file test yang sama atau di file baru di `test/`.

```bash
forge test -vvv
```

### ✔️ Cek mandiri dengan `check.sh`

Benar atau tidaknya pekerjaanmu ditentukan oleh `check.sh`:

```bash
./check.sh A      # cek Part A saja
./check.sh        # cek semua part
```

**Cara kerjanya:** test milikmu dijalankan terhadap beberapa versi kontrak, yaitu versi asli, versi yang salah satu bug-nya sudah diperbaiki, dan versi yang **sengaja dirusak** (*mutation testing*). PoC yang benar harus **lulus** di kontrak asli (bug terbukti ada) dan **gagal** ketika bug itu diperbaiki.

Contoh output:

```text
── Part B: PoC FlashLender (test_PoC_*)
   ✅ Semua PoC lulus di kontrak asli (bug terbukti ada)
   ❌ Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)
```

Supaya bisa dikenali `check.sh`, **nama test wajib** mengikuti aturan berikut:

| Part | Nama fungsi |
|---|---|
| A | `test_HonestFlashLoanPaysFee()` |
| B, C | diawali `test_PoC_`, satu PoC per temuan, contoh `test_PoC_NamaBugnya()` |

> ⚠️ `check.sh` hanya mengecek **kode**. Penjelasan di `ANSWERS.md` dan `FINDINGS.md` adalah bukti bahwa kamu paham, dan tim BCC UKDW bisa memintamu menjelaskannya kapan saja. Semua ✅ tetapi tidak bisa menjelaskan = belum lulus.
>
> Versi-versi kontrak pembanding disimpan dalam base64 di `.check-data` supaya tidak membocorkan jawaban. Men-decode-nya sebelum selesai sama saja dengan menyontek diri sendiri.
>
> Pengguna Windows: jalankan dari terminal **Ubuntu (WSL)**, lihat [panduan instalasi](../../README.md#️-instalasi-cukup-sekali).

---

## 🔍 Kontrak yang Diaudit

| File | nSLOC | Status |
|---|---|---|
| [`src/FlashLender.sol`](./src/FlashLender.sol) | 44 | ✅ In scope |
| [`src/CollateralLoan.sol`](./src/CollateralLoan.sol) | 45 | ✅ In scope |
| [`src/SimpleAMM.sol`](./src/SimpleAMM.sol) | 34 | ❌ Di luar scope, anggap benar |
| [`src/mocks/MockToken.sol`](./src/mocks/MockToken.sol) | 40 | ❌ Di luar scope |

**Jangan mengubah kontrak di `src/`.** Posisikan dirimu sebagai auditor eksternal.

### Alur protokol

```text
                   deposit / redeem                        flashLoan(receiver, amount, data)
   LP  ───────────────────────────────►  FlashLender  ─────────────────────────────────────►  Receiver
                                             ▲                                                   │
                                             └──────── pinjaman + fee wajib kembali ◄────────────┘
                                                       sebelum flashLoan selesai

                 depositCollateral(TKN)                       getPrice()
 Peminjam  ─────────────────────────────►  CollateralLoan  ──────────────►  SimpleAMM (harga spot TKN)
           ◄───────────── borrow(WETH) ─────────┘
```

### Ringkasan fungsi

**FlashLender**

| Fungsi | Keterangan |
|---|---|
| `deposit(amount)` | LP menyetor WETH dan mendapat shares sesuai nilai share saat ini |
| `redeem(shares)` | LP menukar shares menjadi WETH (pokok + bagian fee) |
| `flashLoan(receiver, amount, data)` | Meminjamkan WETH ke `receiver`, memanggil `executeOperation`, lalu memastikan pinjaman + fee sudah kembali |
| `getFee(amount)` | Fee 0.3% dari `amount` |

**CollateralLoan**

| Fungsi | Keterangan |
|---|---|
| `depositCollateral(amount)` | Menyetor TKN sebagai jaminan |
| `borrow(amount)` | Meminjam WETH, maksimal `maxBorrow(user)` |
| `repay(amount)` | Mengembalikan pinjaman |
| `withdrawCollateral(amount)` | Menarik jaminan selama posisi tetap aman |
| `getPrice()` | Harga 1 TKN dalam WETH (presisi 1e18) |
| `maxBorrow(user)` | 50% dari nilai jaminan pengguna |

`check.sh` mengecek **tepat 2 temuan**: satu di `FlashLender`, satu di `CollateralLoan`. Letaknya sengaja tidak ditunjukkan.

### Di luar scope / known issues

Hal-hal berikut **disengaja** dan tidak dihitung sebagai temuan oleh `check.sh`:

- `SimpleAMM` dan `MockToken` dianggap benar. `MockToken.mint` sengaja terbuka untuk pengujian.
- `CollateralLoan` sengaja disederhanakan: tidak ada bunga dan tidak ada likuidasi.
- Fee flash loan dibulatkan ke bawah, sehingga pinjaman di bawah 334 wei tidak membayar fee (Informational).
- Kontrak *receiver* bertanggung jawab memeriksa siapa yang memanggil `executeOperation`. Ini urusan receiver, bukan `FlashLender`.

### 📝 Tugas membaca (sebelum menulis kode)

Isi tabel ini di `ANSWERS.md`:

| Fungsi | Mengubah `totalAssets`? | Mengubah `totalShares`? | Saldo WETH lender berubah? | External call? |
|---|---|---|---|---|
| `deposit` | ? | ? | ? | ? |
| `redeem` | ? | ? | ? | ? |
| `flashLoan` | ? | ? | ? | ? |

---

## 🅰️ Part A — Memahami Flash Loan yang Jujur

Sebelum menyerang, pahami dulu cara kerja normalnya. Auditor yang baik selalu menulis test untuk *happy path* lebih dulu, seperti di lesson *Improving Test Coverage to Find a High*.

### Tugas A1 — Receiver yang jujur

Buat kontrak `HonestReceiver` yang mengimplementasikan `IFlashLoanReceiver`. Di dalam `executeOperation`, kembalikan pinjaman **beserta fee** ke `FlashLender`.

### Tugas A2 — Test happy path

Buat:

```solidity
function test_HonestFlashLoanPaysFee() public {
    // Implementasikan sendiri
}
```

**Persyaratan:**

1. `HonestReceiver` meminjam sebagian WETH dari `lender` dan mengembalikannya beserta fee. Dari mana receiver mendapat WETH untuk membayar fee?
2. Pastikan fee benar-benar **menjadi milik LP**: periksa state akuntansi lender **dan** buktikan bahwa `lp` bisa me-redeem lebih dari yang dia setor.

Jawab di `ANSWERS.md`:

1. Jelaskan urutan eksekusi `flashLoan` baris per baris. Kapan dana keluar, kapan `executeOperation` dipanggil, kapan pengecekan dilakukan?
2. Apa yang terjadi kalau `executeOperation` tidak mengembalikan dana? Buktikan dengan `vm.expectRevert`.
3. Assertion mana yang benar-benar membuktikan bahwa fee menjadi milik LP? Kenapa cukup mengecek "flash loan tidak revert" **tidak** cukup?

<details>
<summary>💡 Hint A-1 (arah)</summary>

Receiver hanya menerima `amount` dari lender, padahal yang harus dikembalikan `amount + fee`. Receiver harus sudah punya WETH sendiri untuk fee. Di test, kamu bisa `mint` WETH ke receiver lebih dulu.

</details>

<details>
<summary>💡 Hint A-2 (konsep)</summary>

Fee masuk ke pool, dan nilai setiap share LP naik. Bandingkan `totalAssets()` sebelum dan sesudah, lalu panggil `redeem` sebagai `lp` (`vm.prank`) dan bandingkan hasilnya dengan 1.000 WETH. Pakai `lender.getFee(amount)` untuk menghitung fee yang diharapkan.

</details>

<details>
<summary>💡 Hint A-3 (hampir jawaban)</summary>

Deploy `HonestReceiver`, mint WETH sebesar fee ke receiver, panggil fungsi receiver yang memanggil `lender.flashLoan(address(this), amount, "")`. Lalu `assertEq(lender.totalAssets(), 1_000 ether + fee)` dan `assertEq` hasil `redeem(1_000 ether)` milik `lp` dengan `1_000 ether + fee`.

</details>

**✔️ Cek mandiri:** `./check.sh A`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅱️ Part B — Audit `FlashLender`

Developer berkata: *"Kami mengecek saldo di akhir, jadi dana pasti kembali."*

Pertanyaan auditor: **dana kembali lewat jalan apa?** Apakah protokol membedakan WETH yang dikembalikan sebagai *pembayaran pinjaman* dari WETH yang masuk lewat jalan lain?

### Tugas B1 — Temukan bug

Telusuri semua cara WETH bisa masuk ke `FlashLender`. Lalu jawab: apakah ada cara mengembalikan dana pinjaman yang **lolos pengecekan saldo** tetapi tetap membuat peminjam **memiliki** dana tersebut?

### Tugas B2 — Buktikan dengan PoC

Tulis kontrak penyerang dan test berawalan `test_PoC_`. PoC kamu harus menunjukkan:

1. Penyerang hanya bermodal sedikit (maksimal 10 WETH milik `attacker`).
2. Di akhir, penyerang membawa pulang WETH **jauh melebihi** modalnya.
3. Dana LP hilang: `lp` tidak bisa lagi me-redeem seluruh sharesnya.

Jawab di `ANSWERS.md`:

1. Jelaskan alur serangan langkah demi langkah, dan tunjukkan nilai `totalAssets`, `totalShares`, serta saldo WETH lender di setiap langkah.
2. Kenapa pengecekan `balanceOf(this) >= balanceBefore + fee` tidak cukup?
3. Berapa keuntungan bersih penyerang? Dari mana asalnya?

<details>
<summary>💡 Hint B-1 (arah)</summary>

Di dalam `executeOperation`, peminjam bebas memanggil fungsi **apa pun** di protokol, termasuk fungsi lain milik `FlashLender` itu sendiri.

</details>

<details>
<summary>💡 Hint B-2 (konsep)</summary>

Tonton ulang [Exploit: Deposit Instead Of Repay](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-deposit-instead-of-repay). Saldo WETH lender naik baik saat dana *dikembalikan* maupun saat dana *disetor*. Bedanya, yang kedua memberi peminjam sesuatu sebagai gantinya.

</details>

<details>
<summary>💡 Hint B-3 (hampir jawaban)</summary>

Di `executeOperation`: `approve` lender, panggil `lender.deposit(amount)`, lalu transfer fee secara terpisah supaya pengecekan saldo lolos. Setelah `flashLoan` selesai, panggil `redeem` untuk shares milik kontrak penyerang. Ingat: kamu mungkin tidak bisa me-redeem **semua** shares, karena `totalAssets` sekarang lebih besar dari saldo WETH yang sebenarnya.

</details>

**✔️ Cek mandiri:** `./check.sh B`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅲 Part C — Audit `CollateralLoan`

Developer berkata: *"Harga kami diambil langsung dari AMM, jadi selalu mengikuti pasar."*

### Tugas C1 — Temukan bug

Perhatikan dari mana `getPrice()` mengambil harga. Lalu jawab: **siapa** yang bisa menggerakkan harga itu, **berapa biayanya**, dan **berapa lama** perubahannya bertahan?

### Tugas C2 — Buktikan dengan PoC

Tulis test berawalan `test_PoC_` yang menunjukkan penyerang bisa meminjam WETH **jauh melebihi nilai wajar** jaminannya.

**Persyaratan:**

1. Seluruh serangan terjadi dalam **satu transaksi**, jadi jangan memakai `vm.roll` atau `vm.warp` di tengah serangan.
2. Modal penyerang hanya 10 WETH dan 1.000 TKN. Kalau butuh modal lebih besar untuk menggeser harga, dari mana kamu bisa meminjamnya **tanpa jaminan**?
3. Assert bahwa utang penyerang jauh lebih besar daripada nilai wajar jaminannya (hitung nilai wajar dari harga **sebelum** serangan).

Jawab di `ANSWERS.md`:

1. Berapa harga TKN sebelum dan sesudah manipulasi? Tunjukkan perhitungannya memakai rumus constant product.
2. Siapa yang menanggung kerugian? Berapa besar *bad debt* yang tercipta?
3. Kenapa kerugian ini tetap terjadi walaupun `SimpleAMM` sendiri tidak punya bug?

<details>
<summary>💡 Hint C-1 (arah)</summary>

Harga spot AMM ditentukan oleh perbandingan reserve. Membeli banyak TKN dengan WETH akan membuat TKN langka di pool, sehingga harganya naik, dan kenaikan itu bertahan sampai ada yang menjual kembali.

</details>

<details>
<summary>💡 Hint C-2 (konsep)</summary>

Tonton ulang [Oracle Manipulation: Minimized](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-oracle-manipulation-minimized). Modal untuk menggeser harga bisa dipinjam dari `FlashLender` yang **jujur** (dibayar kembali dengan benar). Jadi serangan ini tidak bergantung pada bug di Part B.

</details>

<details>
<summary>💡 Hint C-3 (hampir jawaban)</summary>

Kontrak penyerang: `flashLoan` 1.000 WETH → di `executeOperation`, swap seluruh WETH menjadi TKN di AMM → `depositCollateral` 1.000 TKN milik penyerang → `borrow` WETH sebesar mungkin (cek `maxBorrow`) → swap balik TKN hasil beli menjadi WETH → bayar pinjaman + fee. Sisa WETH adalah keuntungan penyerang.

</details>

**✔️ Cek mandiri:** `./check.sh C`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅳 Part D — Laporan Audit

Tulis kedua temuanmu di `FINDINGS.md` dengan format profesional: Title, Severity (Impact & Likelihood), Description, Impact, Proof of Concept, dan Recommended Mitigation.

Jawab juga di `ANSWERS.md`:

1. **Mitigasi FlashLender:** sebutkan minimal dua cara memperbaiki bug di Part B. Apa kelebihan dan kekurangan masing-masing? (Petunjuk: bandingkan dengan pola di [EIP-3156](https://eips.ethereum.org/EIPS/eip-3156).)
2. **Mitigasi CollateralLoan:** bandingkan TWAP ([Uniswap V2 Oracles](https://docs.uniswap.org/contracts/v2/concepts/core-concepts/oracles)) dan oracle terdesentralisasi ([Chainlink](https://docs.chain.link/data-feeds)). Apakah TWAP sepenuhnya kebal manipulasi?
3. **Flash loan itu jahat?** Menurutmu, apakah akar masalah di Part C adalah flash loan atau oracle-nya? Jelaskan dengan merujuk lesson *Are Flash Loans Bad?*.
4. **Severity:** kenapa kamu memberi severity seperti itu untuk setiap temuan?

---

## 🏁 Kriteria Keberhasilan

| Part | Kriteria | Bukti |
|---|---|---|
| A | Test happy path membuktikan fee benar-benar menjadi milik LP. | `./check.sh A` semua ✅ |
| B | Bug di `FlashLender` ditemukan dan dibuktikan dengan kontrak penyerang. | `./check.sh B` semua ✅ + alur angka di `ANSWERS.md` |
| C | Bug di `CollateralLoan` dibuktikan dalam satu transaksi dengan modal kecil. | `./check.sh C` semua ✅ + perhitungan harga |
| D | Dua finding ditulis lengkap dengan mitigasi yang masuk akal. | `FINDINGS.md` + jawaban D1–D4 |

---

## 🚀 Mulai Sekarang

1. Tonton materi **Part 0** di Cyfrin Updraft.
2. Isi **Tabel Fungsi** di `ANSWERS.md`.
3. Kerjakan **Part A**, lalu jalankan `./check.sh A`.
4. Semua ✅? Lanjut ke Part B, dan seterusnya.

Target akhirnya: kamu bisa melihat sebuah protokol DeFi dan langsung bertanya, *"Kalau aku punya modal tak terbatas selama satu transaksi, apa yang bisa kurusak?"*
