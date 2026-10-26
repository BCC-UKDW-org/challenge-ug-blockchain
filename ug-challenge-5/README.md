# Challenge 05 — Mini AMM

| | |
|---|---|
| **Level** | Intermediate |
| **Basis materi** | [Cyfrin Updraft — Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **TSwap** (Invariants & Intro to DeFi) |
| **Tools** | Solidity, Foundry (Forge) |
| **Estimasi waktu** | Menonton materi ±5 jam + mengerjakan 60–120 menit per part |
| **Fokus** | AMM constant product, stateless vs stateful fuzzing, handler untuk DeFi, slippage, deadline, compiler sebagai static analysis |
| **Cek jawaban** | `./check.sh` (lihat [Cek mandiri](#️-cek-mandiri-dengan-checksh)) |

> ⚠️ **Sebelum mulai, baca [Aturan Utama](../README.md#️-aturan-utama--wajib-dibaca).**
> AI hanya boleh dipakai seperti Google, yaitu untuk mencari dokumentasi dan konsep. **Kode, penjelasan, dan laporan harus kamu tulis sendiri.**

---

## 🎯 Misi Kamu

Sebuah tim membangun `MiniPool`, sebuah **AMM (Automated Market Maker)** sederhana yang terinspirasi Uniswap V2. Pengguna bisa:

- Menyetor sepasang token (`tokenX` dan `tokenY`) sebagai likuiditas, lalu menerima *share*.
- Menukar `tokenX` ↔ `tokenY` dengan harga yang ditentukan rumus **x · y = k**.
- Menarik kembali likuiditasnya beserta fee yang terkumpul.

Developer mengklaim:

> *"Fee 0.3% selalu tinggal di pool, jadi x · y tidak pernah turun karena swap. Pengguna juga dilindungi dari slippage dan transaksi basi lewat parameter `minAmountOut`/`maxAmountIn` dan `deadline`."*

Di UG-1 kamu belajar membangun handler untuk vault sederhana. Sekarang kamu memakai skill yang sama untuk protokol DeFi sungguhan. **Tugasmu adalah membuktikan apakah klaim di atas benar, dengan test.**

### Setelah menyelesaikan challenge ini, kamu akan bisa:

1. Menjelaskan cara kerja AMM constant product dan menghitung satu swap secara manual.
2. Menulis **stateless fuzz test** untuk fungsi matematika, dan menjelaskan **kapan stateless fuzzing tidak cukup**.
3. Membangun **handler** yang melakukan swap dua arah untuk menguji invariant `x · y = k`.
4. Memanfaatkan **warning compiler** sebagai alat static analysis.
5. Menulis PoC untuk bug fee, slippage, dan deadline, **masing-masing fokus pada satu bug**.
6. Menganalisis risiko **weird ERC20** terhadap AMM.

---

## 📺 Part 0 — Wajib Tonton Cyfrin Updraft Dulu

Challenge ini dibangun di atas section **TSwap** dari course [Smart Contract Security](https://updraft.cyfrin.io/courses/security). Tonton dulu materinya **sebelum** membuka soal. Konsep AMM dan stateful fuzzing hampir mustahil dipahami hanya dari membaca kode.

### ✅ Wajib

**Dasar DeFi & AMM**

- [ ] [What is a DEX?](https://updraft.cyfrin.io/courses/security/tswap/what-is-a-dex)
- [ ] [What is an AMM?](https://updraft.cyfrin.io/courses/security/tswap/what-is-amm)
- [ ] [Liquidity Providers](https://updraft.cyfrin.io/courses/security/tswap/liquidity-providers)
- [ ] [How AMMs Work](https://updraft.cyfrin.io/courses/security/tswap/how-amms-work)
- [ ] [Constant Product Formula Explained](https://updraft.cyfrin.io/courses/security/tswap/constant-product-formula-explained)

**Stateless vs stateful fuzzing**

- [ ] [Stateful And Stateless Fuzzing](https://updraft.cyfrin.io/courses/security/tswap/stateful-and-stateless-fuzzing)
- [ ] [Where Stateless Fuzzing Fails](https://updraft.cyfrin.io/courses/security/tswap/where-stateless-fuzzing-fails)
- [ ] [Stateful Fuzzing Method 2](https://updraft.cyfrin.io/courses/security/tswap/stateful-fuzzing-method-2)

**Menulis test suite invariant untuk AMM**

- [ ] ⭐ [Writing Stateful Fuzz Test Suite](https://updraft.cyfrin.io/courses/security/tswap/writing-stateful-fuzz-test-suite)
- [ ] [Invariant.t.sol](https://updraft.cyfrin.io/courses/security/tswap/invariant-t-sol)
- [ ] [Handler.t.sol](https://updraft.cyfrin.io/courses/security/tswap/handler-t-sol)
- [ ] [Handler Swap Function](https://updraft.cyfrin.io/courses/security/tswap/handler-swap-function)
- [ ] [Final Invariant And Tweaks](https://updraft.cyfrin.io/courses/security/tswap/final-invariant-and-tweaks)
- [ ] [Debugging The Fuzzer](https://updraft.cyfrin.io/courses/security/tswap/debugging-the-fuzzer)

**Manual review & reporting**

- [ ] [Using The Compiler As Static Analysis Tool](https://updraft.cyfrin.io/courses/security/tswap/using-the-compiler-as-static-analysis-tool)
- [ ] [Reporting: Missing Deadline](https://updraft.cyfrin.io/courses/security/tswap/missing-deadline-write-up)
- [ ] [Reporting: No Slippage Protection](https://updraft.cyfrin.io/courses/security/tswap/no-slippage-protection)
- [ ] [Reporting: Invariant Break & PoC](https://updraft.cyfrin.io/courses/security/tswap/invariant-break-write-up-and-poc)
- [ ] [Weird ERC20s](https://updraft.cyfrin.io/courses/security/tswap/weird-erc20)

> Codebase yang diaudit di video adalah [Cyfrin/5-t-swap-audit](https://github.com/Cyfrin/5-t-swap-audit). `MiniPool` di challenge ini adalah kontrak **berbeda** dengan bug **sejenis**. Laporan TSwap tidak bisa disalin begitu saja, tetapi cara berpikirnya bisa kamu pakai.

### 🎮 Latihan pendamping (opsional)

- [Ethernaut](https://ethernaut.openzeppelin.com/), level **Dex** dan **Dex Two**: manipulasi harga pada DEX sederhana.

### 📖 Dokumentasi pendamping

| Topik | Sumber |
|---|---|
| Cara kerja Uniswap V2 | [Uniswap Docs — How Uniswap Works](https://docs.uniswap.org/contracts/v2/concepts/protocol-overview/how-uniswap-works), [Pricing](https://docs.uniswap.org/contracts/v2/concepts/advanced-topics/pricing) |
| Whitepaper Uniswap V2 | [uniswap.org/whitepaper.pdf](https://uniswap.org/whitepaper.pdf) |
| Fuzz & invariant testing | [Foundry Book — Fuzz Testing](https://getfoundry.sh/forge/fuzz-testing), [Invariant Testing](https://getfoundry.sh/forge/invariant-testing) |
| Membatasi input | [forge-std — `bound()`](https://getfoundry.sh/reference/forge-std/bound) |
| Mengatur waktu blok | [Cheatcode `vm.warp`](https://getfoundry.sh/reference/cheatcodes/warp) |
| Daftar token ERC20 "aneh" | [d-xo/weird-erc20](https://github.com/d-xo/weird-erc20) |

### ✅ Self-check sebelum mulai

- [ ] Kalau reserve 100 X dan 100 Y, kenapa menukar 50 X **tidak** menghasilkan 50 Y?
- [ ] Dari mana keuntungan liquidity provider berasal?
- [ ] Apa beda `swapExactInput` dan `swapExactOutput`? Parameter apa yang melindungi pengguna di masing-masing fungsi?
- [ ] Apa itu **slippage**, dan bagaimana penyerang bisa memanfaatkannya (*sandwich attack*)?
- [ ] Kenapa transaksi swap butuh **deadline**?
- [ ] Contoh bug apa yang **tidak bisa** ditemukan stateless fuzzing tetapi bisa ditemukan stateful fuzzing?

---

## 🧰 Setup

```bash
cd ug-challenge-5
forge build
```

Struktur folder:

```text
ug-challenge-5/
├── src/
│   ├── MiniPool.sol          ← kontrak yang diaudit (JANGAN diubah)
│   └── mocks/MockToken.sol   ← token untuk pengujian (di luar scope)
├── test/
│   └── MiniPool.t.sol        ← kerangka test: tulis test-mu di sini
├── ANSWERS.md                ← penjelasan & jawaban per part
├── FINDINGS.md               ← laporan bug (Part D)
├── check.sh                  ← cek mandiri
└── foundry.toml
```

Kerangka test sudah menyiapkan pool berisi likuiditas awal 100 X : 100 Y, trader `alice`, dan `attacker`. Keduanya punya modal 1.000 token X dan Y dan sudah memberi approve ke pool. Semua test ditulis di folder `test/`. Kamu boleh menambah file, misalnya `test/Handler.sol`.

```bash
forge test -vvv
```

### ✔️ Cek mandiri dengan `check.sh`

```bash
./check.sh A      # cek Part A saja
./check.sh        # cek semua part
```

`check.sh` menjalankan test-mu terhadap kontrak asli, versi yang sudah diperbaiki, dan versi yang **sengaja dirusak** (*mutation testing*). Test yang baik harus **lulus** di versi yang benar dan **gagal** di versi yang rusak.

Contoh output:

```text
── Part C: test_PoC_*
   ✅ Semua PoC lulus di kontrak asli (bug terbukti ada)
   ✅ Temuan #1 terbukti (ada PoC yang gagal hanya ketika bug ini diperbaiki)
   ❌ Temuan #2 terbukti (ada PoC yang gagal hanya ketika bug ini diperbaiki)
```

**Nama test wajib:**

| Part | Nama fungsi |
|---|---|
| A | `testFuzz_GetOutputAmount(...)` (parameter bebas) |
| B | `invariant_ConstantProduct()` |
| C | diawali `test_PoC_`, satu PoC untuk setiap temuan, contoh `test_PoC_NamaBugnya()` |

> ⚠️ `check.sh` hanya mengecek **kode**. Penjelasan di `ANSWERS.md` dan `FINDINGS.md` adalah bukti bahwa kamu paham, dan menjadi bahan tanya jawab saat praktikum.
>
> Versi-versi kontrak pembanding disimpan dalam base64 di `.check-data` supaya tidak membocorkan jawaban. Men-decode-nya sebelum selesai sama saja dengan menyontek diri sendiri.
>
> Pengguna Windows: jalankan dari terminal **Ubuntu (WSL)**, lihat [panduan instalasi](../README.md#️-instalasi-cukup-sekali).

---

## 🔍 Kontrak yang Diaudit

| File | nSLOC | Scope |
|---|---|---|
| [`src/MiniPool.sol`](./src/MiniPool.sol) | 111 | ✅ Diaudit |
| [`src/mocks/MockToken.sol`](./src/mocks/MockToken.sol) | 40 | ❌ Di luar scope (token untuk pengujian, `mint` sengaja terbuka) |

**Aktor:**

- **Liquidity provider (LP):** menyetor `tokenX` + `tokenY`, menerima `shares`, dan mendapat bagian fee.
- **Trader:** menukar token lewat `swapExactInput` atau `swapExactOutput`.

**Fungsi penting di `MiniPool`:**

| Fungsi | Kegunaan |
|---|---|
| `addLiquidity(amountX, amountY)` | Menyetor likuiditas dan menerima `shares`. Deposit pertama menentukan rasio harga. |
| `removeLiquidity(shareAmount)` | Membakar `shares` dan menerima token X dan Y secara proporsional. |
| `getOutputAmount(in, inRes, outRes)` | Rumus output untuk input tertentu (setelah fee 0.3%). |
| `getInputAmount(out, inRes, outRes)` | Rumus input yang dibutuhkan untuk output tertentu (setelah fee 0.3%). |
| `swapExactInput(tokenIn, amountIn, minAmountOut, deadline)` | "Saya bayar tepat `amountIn`, beri saya output minimal `minAmountOut`." |
| `swapExactOutput(tokenIn, amountOut, maxAmountIn, deadline)` | "Saya mau tepat `amountOut`, dan saya mau bayar paling banyak `maxAmountIn`." |

Reserve pool selalu dibaca dari `balanceOf` token milik pool. Baca NatSpec di [`src/MiniPool.sol`](./src/MiniPool.sol) dengan teliti, karena di situlah perilaku yang **dimaksud** developer dituliskan. Bug adalah penyimpangan dari perilaku itu.

**`check.sh` mengecek tepat 4 temuan.**

### Di luar scope / known issues

Hal-hal berikut **bukan** temuan yang dicari di challenge ini:

- `MockToken` dan fungsi `mint`-nya.
- Pool tidak memiliki LP token ERC20; `shares` hanya disimpan sebagai mapping. Ini keputusan desain.
- Karena reserve dibaca dari `balanceOf`, siapa pun bisa "mendonasikan" token ke pool. Donasi menguntungkan LP dan tidak merugikan pengguna lain. Deposit pertama minimal `1e15` untuk mencegah serangan pembulatan share.
- Token ERC20 "aneh" tidak didukung. Ini menjadi bahan diskusi di Part D, bukan temuan yang dicek.

### 📝 Tugas membaca (sebelum menulis kode)

Isi di `ANSWERS.md`:

1. Tabel efek setiap fungsi publik terhadap reserve X, reserve Y, `totalShares`, dan `swapCount`.
2. **Hitung manual:** pool berisi 100 X dan 100 Y. Alice memanggil `swapExactInput(X, 10e18, ...)`. Berapa Y yang ia terima menurut rumus di `getOutputAmount`? Berapa `k` sebelum dan sesudah swap?
3. Jalankan `forge build`. Warning apa yang muncul dari `src/MiniPool.sol`, dan apa artinya bagi seorang auditor?

---

## 🅰️ Part A — Stateless Fuzzing pada Rumus Swap

Rumus `getOutputAmount` adalah jantung AMM. Kalau rumus ini salah, `x · y` bisa turun dan LP kehilangan dana.

### Tugas A1

Tulis `testFuzz_GetOutputAmount(...)` yang menerima `amountIn`, `inputReserve`, dan `outputReserve` acak, lalu memastikan:

1. Output **selalu lebih kecil** dari reserve output (pool tidak pernah kosong).
2. Setelah swap hipotetis, `(inputReserve + amountIn) * (outputReserve - amountOut)` **tidak lebih kecil** dari `inputReserve * outputReserve`.

Pikirkan rentang input yang masuk akal. Input yang tidak realistis akan membuat test gagal karena *overflow*, bukan karena bug.

### Tugas A2 — Pertanyaan

Jawab di `ANSWERS.md`:

1. Rentang apa yang kamu pilih untuk tiap parameter, dan kenapa?
2. Test ini **lulus** di kontrak asli. Apakah itu berarti `MiniPool` aman? Bug jenis apa yang **mustahil** ditemukan oleh test yang hanya memanggil satu fungsi `pure`?

<details>
<summary>💡 Hint A-1 (arah)</summary>

Properti yang diuji adalah aturan constant product: setelah swap, `k` baru tidak boleh lebih kecil dari `k` lama. Kamu tidak perlu melakukan swap sungguhan. Cukup panggil fungsi `pure`, lalu hitung `k` sebelum dan sesudahnya di dalam test.

</details>

<details>
<summary>💡 Hint A-2 (konsep)</summary>

Tonton ulang [Stateless Fuzzing](https://updraft.cyfrin.io/courses/security/tswap/stateless-fuzzing) dan baca [`bound()`](https://getfoundry.sh/reference/forge-std/bound). Reserve yang terlalu kecil (atau nol) dan input yang jauh lebih besar dari reserve tidak realistis. Perhatikan juga perkalian yang bisa melebihi `type(uint256).max`.

</details>

<details>
<summary>💡 Hint A-3 (hampir jawaban)</summary>

Batasi kedua reserve ke kisaran `[1e15, 1e30]` dan `amountIn` ke `[1, inputReserve]`. Panggil `pool.getOutputAmount(...)`, lalu gunakan `assertLt` untuk syarat 1 dan `assertGe` untuk syarat 2. Fungsi test-nya bisa diberi `view`.

</details>

**✔️ Cek mandiri:** `./check.sh A`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅱️ Part B — Stateful Fuzzing: Invariant `x · y = k`

Rumusnya benar, tetapi apakah **urutan** swap juga selalu menjaga `x · y`? Untuk itu kamu butuh stateful fuzzing.

### Tugas B1 — Handler

Buat handler (seperti di UG-1) yang **hanya melakukan swap**, dua arah, lewat **kedua** fungsi swap:

```solidity
contract Handler is Test {
    // simpan pool, token, dan alamat trader

    function swapExactInput(bool xToY, uint256 amountIn) external {
        // 1. tentukan arah swap
        // 2. jepit amountIn ke rentang yang wajar
        // 3. pastikan trader punya token & approve
        // 4. catat k sebelum swap, swap, catat k sesudah swap
    }

    function swapExactOutput(bool xToY, uint256 amountOut) external {
        // sama, tetapi untuk swapExactOutput
    }
}
```

Likuiditas awal cukup ditambahkan sekali di `setUp()`. **Jangan** masukkan `addLiquidity`/`removeLiquidity` ke handler, karena keduanya memang mengubah `k` secara sah.

### Tugas B2 — Invariant

Tulis `invariant_ConstantProduct()` yang memastikan **`k` tidak pernah turun akibat swap**. Daftarkan handler dengan `targetContract`, lalu jalankan:

```bash
forge test --match-test invariant_ConstantProduct -vvv
```

Jawab di `ANSWERS.md`:

1. Bagaimana cara invariant-mu "mengetahui" nilai `k` sebelum dan sesudah swap? (Petunjuk: *ghost variables* di handler.)
2. Kalau invariant gagal, tempel **call sequence**-nya dan jelaskan langkah demi langkah. Pola apa yang kamu lihat? Berapa swap yang terjadi sebelum `k` turun?
3. Kenapa Part A **tidak bisa** menemukan masalah ini, sedangkan Part B bisa?

<details>
<summary>💡 Hint B-1 (arah)</summary>

Trader di handler butuh token sebelum swap. Karena `MockToken.mint` terbuka, handler bisa me-*mint* sendiri token yang dibutuhkan. Untuk `swapExactOutput`, tanyakan dulu ke pool berapa input yang dibutuhkan, lalu mint sejumlah itu.

</details>

<details>
<summary>💡 Hint B-2 (konsep)</summary>

Tonton [Handler.t.sol](https://updraft.cyfrin.io/courses/security/tswap/handler-t-sol), [Handler Swap Function](https://updraft.cyfrin.io/courses/security/tswap/handler-swap-function), dan [Debugging The Fuzzer](https://updraft.cyfrin.io/courses/security/tswap/debugging-the-fuzzer). Ingat juga pelajaran UG-1: invariant yang lulus karena semua panggilan revert itu menipu. Perhatikan kolom `reverts` di output.

</details>

<details>
<summary>💡 Hint B-3 (hampir jawaban)</summary>

Di handler, simpan dua variabel publik `kBefore` dan `kAfter`, yang diisi tepat sebelum dan sesudah setiap swap (`k = tokenX.balanceOf(pool) * tokenY.balanceOf(pool)`). Batasi `amountIn` misalnya ke `[1e15, 10e18]` dan `amountOut` ke `[1e15, reserveOut / 10]`. Invariant-nya cukup satu baris: `assertGe(handler.kAfter(), handler.kBefore())`.

</details>

**✔️ Cek mandiri:** `./check.sh B`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅲 Part C — Proof of Code untuk Setiap Temuan

Fuzzer menemukan satu masalah. Seorang auditor tidak berhenti di situ. Baca ulang `MiniPool.sol` baris demi baris (dan ingat warning compiler dari tugas membaca). **Ada 4 temuan yang dicek.**

Tulis **satu PoC untuk setiap temuan**, dengan nama diawali `test_PoC_`. Setiap PoC harus:

1. **Lulus** di kontrak asli, yang berarti bug terbukti ada.
2. **Gagal** kalau bug itu diperbaiki.
3. **Tetap lulus** kalau bug **lain** yang diperbaiki. Artinya, setiap PoC fokus pada satu bug saja.

> **Kenapa syarat nomor 3 penting?** Misalnya PoC untuk bug A kamu panggil dengan `maxAmountIn = 0` "asal jalan". PoC itu ikut gagal begitu proteksi slippage diperbaiki, padahal yang ingin kamu buktikan adalah bug A. PoC seperti itu salah sasaran. Gunakan nilai yang realistis: misalnya `maxAmountIn` diambil dari quote `pool.getInputAmount(...)` sesaat sebelum swap, dan `deadline` diisi `block.timestamp` kecuali memang deadline yang sedang kamu uji.

Jawab di `ANSWERS.md` untuk setiap temuan: apa yang **dijanjikan** NatSpec, apa yang **sebenarnya** terjadi, dan bagaimana PoC-mu membuktikannya.

<details>
<summary>💡 Hint C-1 (arah)</summary>

- Satu temuan sudah kamu lihat lewat call sequence di Part B.
- Dua temuan terlihat dari warning compiler di `forge build`.
- Satu temuan ada pada angka: bandingkan rumus fee di `getOutputAmount` dan `getInputAmount` dengan teliti.

</details>

<details>
<summary>💡 Hint C-2 (konsep)</summary>

Tonton [Reporting: Invariant Break & PoC](https://updraft.cyfrin.io/courses/security/tswap/invariant-break-write-up-and-poc), [Reporting: No Slippage Protection](https://updraft.cyfrin.io/courses/security/tswap/no-slippage-protection), dan [Reporting: Missing Deadline](https://updraft.cyfrin.io/courses/security/tswap/missing-deadline-write-up). Untuk mensimulasikan *front-running*, cukup buat `attacker` melakukan swap besar tepat sebelum transaksi korban. Untuk menguji deadline, gunakan [`vm.warp`](https://getfoundry.sh/reference/cheatcodes/warp).

</details>

<details>
<summary>💡 Hint C-3 (hampir jawaban)</summary>

1. Lakukan beberapa `swapExactInput` kecil berturut-turut, lalu bandingkan `k` sebelum dan sesudah swap ke-*N* (lihat call sequence Part B).
2. Hitung input yang **adil** dengan rumus fee 0.3% yang benar di dalam test, lalu bandingkan dengan yang benar-benar dibayar lewat `swapExactOutput`. Selisihnya jauh, bukan sekadar pembulatan.
3. Ambil quote `getInputAmount` sebagai `maxAmountIn`, biarkan `attacker` swap besar ke arah yang sama, lalu tunjukkan korban membayar **lebih** dari `maxAmountIn` dan transaksinya tetap berhasil.
4. `vm.warp` ke masa depan, panggil `swapExactOutput` dengan `deadline` yang sudah lewat, lalu tunjukkan swap tetap berhasil.

</details>

**✔️ Cek mandiri:** `./check.sh C`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅳 Part D — Laporan & Diskusi Weird ERC20

### Tugas D1 — Laporan

Tulis keempat temuan di `FINDINGS.md` menggunakan template yang tersedia: Title, Severity (Impact & Likelihood), Description, Impact, Proof of Code, dan Recommended Mitigation. Tentukan severity dengan alasan yang jelas. Contohnya, mana yang lebih berbahaya: pengguna membayar 10× lipat, atau swap yang dieksekusi setelah deadline?

### Tugas D2 — Diskusi weird ERC20 (tidak dicek `check.sh`)

Tonton [Weird ERC20s](https://updraft.cyfrin.io/courses/security/tswap/weird-erc20) dan baca [d-xo/weird-erc20](https://github.com/d-xo/weird-erc20). Jawab di `ANSWERS.md`:

1. Kalau `tokenX` adalah token **fee-on-transfer** (misalnya memotong 1% di setiap transfer), apa yang terjadi pada reserve pool setelah `swapExactInput`? Siapa yang dirugikan?
2. Kalau `tokenY` adalah token **rebasing** yang saldonya bisa turun sendiri, apa dampaknya pada `x · y = k` dan pada LP?
3. Token seperti USDT tidak mengembalikan `bool` pada `transfer`. Apa yang terjadi kalau token seperti itu dipakai di `MiniPool`? Lihat fungsi `_pull` dan `_push`.
4. Token **ERC777** memanggil *hook* milik penerima saat transfer. Dengan urutan transfer di `_swap`, apakah ada peluang reentrancy?

**✔️ Cek mandiri:** Part D tidak dicek otomatis. Pastikan kamu bisa menjelaskan setiap jawabanmu.

---

## 🏁 Kriteria Keberhasilan

| Part | Kriteria | Bukti |
|---|---|---|
| A | Stateless fuzz menguji properti `x · y` pada rumus output dengan input yang realistis. | `./check.sh A` semua ✅ |
| B | Handler melakukan swap dua arah lewat kedua fungsi swap, dan invariant menemukan pelanggaran. | `./check.sh B` semua ✅ + call sequence |
| C | Empat temuan dibuktikan, masing-masing dengan PoC yang fokus pada satu bug. | `./check.sh C` semua ✅ |
| D | Laporan profesional untuk keempat temuan + analisis weird ERC20. | `FINDINGS.md` & `ANSWERS.md` |

---

## 🚀 Mulai Sekarang

1. Tonton materi **Part 0** di Cyfrin Updraft.
2. Kerjakan **Tugas membaca** di `ANSWERS.md`.
3. Kerjakan **Part A**, lalu jalankan `./check.sh A`.
4. Semua ✅? Lanjut ke Part B, dan seterusnya.

Target akhirnya: kamu bisa mengaudit sebuah AMM dengan kombinasi fuzzing dan manual review, lalu melaporkan setiap temuan dengan PoC yang tepat sasaran, **tanpa bergantung pada AI**.
