# Challenge 04 — Lucky Draw II

| | |
|---|---|
| **Level** | Intermediate |
| **Basis materi** | [Cyfrin Updraft — Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **Puppy Raffle** (DoS, Weak Randomness, Integer Overflow, Unsafe Casting, Static Analysis) |
| **Tools** | Solidity, Foundry (Forge), Slither (opsional), Aderyn (opsional) |
| **Estimasi waktu** | Menonton materi ±3 jam + mengerjakan 2–3 jam |
| **Fokus** | Static analysis, Denial of Service, randomness on-chain, integer overflow & unsafe casting, menulis laporan audit |
| **Cek jawaban** | `./check.sh` (lihat [Cek mandiri](#️-cek-mandiri-dengan-checksh)) |

> ⚠️ **Sebelum mulai, baca [Aturan Utama](../README.md#️-aturan-utama--wajib-dibaca).**
> AI hanya boleh dipakai seperti Google, yaitu untuk mencari dokumentasi dan konsep. **Kode, penjelasan, dan laporan harus kamu tulis sendiri.**

---

## 🎯 Misi Kamu

Di Challenge 03, kamu menemukan bug di `LuckyDraw`. Developer berterima kasih, memperbaiki semuanya (refund kini mengikuti Checks-Effects-Interactions, hadiah dibayar dengan pola *pull payment*), lalu merilis versi baru: **`LuckyDrawV2`**.

Fitur baru di V2:

- Satu transaksi bisa mendaftarkan **banyak pemain sekaligus** (misalnya untuk satu tongkrongan).
- **Siapa saja** boleh menarik pemenang, tidak perlu menunggu owner.
- Pemenang dipilih secara **"acak dan adil"**, mendapat 80% dari total tiket, dan 20% sisanya menjadi fee untuk owner.

Developer mengklaim: *"Semua temuan audit sebelumnya sudah diperbaiki. V2 aman untuk dipakai ribuan pemain."*

**Tugasmu adalah membuktikan apakah klaim itu benar, dengan test, bukan dengan opini.**

### Setelah menyelesaikan challenge ini, kamu akan bisa:

1. Menjalankan **static analysis** (compiler/linter, Slither, Aderyn) dan memilah *true positive* dari *false positive*.
2. Membuktikan **Denial of Service** berbasis gas dengan mengukur gas di Foundry.
3. Menjelaskan mengapa nilai on-chain seperti `block.timestamp` dan `block.prevrandao` **bukan sumber acak**, lalu mengeksploitasinya.
4. Membedakan **overflow yang di-revert** oleh Solidity ≥0.8 dari **unsafe casting** yang memotong nilai diam-diam.
5. Menulis tiga finding dengan format laporan audit profesional.

---

## 📺 Part 0 — Wajib Tonton Cyfrin Updraft Dulu

Challenge ini dibangun di atas materi **Cyfrin Updraft**. Tonton dulu materinya **sebelum** membuka soal. Tanpa konteks dari video, kamu akan kesulitan dan tergoda menyuruh AI mengerjakannya.

### ✅ Wajib

Section **Puppy Raffle** dari course [Smart Contract Security](https://updraft.cyfrin.io/courses/security):

**Static analysis**

- [ ] [Tooling: Slither](https://updraft.cyfrin.io/courses/security/puppy-raffle/tooling-slither)
- [ ] [Tooling: Aderyn](https://updraft.cyfrin.io/courses/security/puppy-raffle/tooling-aderyn)
- [ ] [Slither Walkthrough](https://updraft.cyfrin.io/courses/security/puppy-raffle/slither-walkthrough)
- [ ] [Aderyn Walkthrough](https://updraft.cyfrin.io/courses/security/puppy-raffle/aderyn-walkthrough)

**Denial of Service**

- [ ] [Exploit: Denial of Service](https://updraft.cyfrin.io/courses/security/puppy-raffle/exploit-denial-of-service)
- [ ] [Case Study: DoS](https://updraft.cyfrin.io/courses/security/puppy-raffle/dos-case-study)
- [ ] ⭐ [DoS PoC](https://updraft.cyfrin.io/courses/security/puppy-raffle/dos-poc)
- [ ] [DoS: Mitigation](https://updraft.cyfrin.io/courses/security/puppy-raffle/dos-mitigation)

**Weak Randomness**

- [ ] ⭐ [Exploit: Weak Randomness](https://updraft.cyfrin.io/courses/security/puppy-raffle/exploit-weak-randomness)
- [ ] [Weak Randomness: Multiple Issues](https://updraft.cyfrin.io/courses/security/puppy-raffle/weak-randomness-multiple-issues)
- [ ] [Case Study: Weak Randomness](https://updraft.cyfrin.io/courses/security/puppy-raffle/weak-randomness-case-study)
- [ ] [Weak Randomness: Mitigation](https://updraft.cyfrin.io/courses/security/puppy-raffle/weak-randomness-mitigation)

**Integer overflow & unsafe casting**

- [ ] [Exploit: Integer Overflow](https://updraft.cyfrin.io/courses/security/puppy-raffle/exploit-integer-overflow)
- [ ] [Integer Overflow: Mitigation](https://updraft.cyfrin.io/courses/security/puppy-raffle/integer-overflow-mitigation)
- [ ] ⭐ [Exploit: Unsafe Casting](https://updraft.cyfrin.io/courses/security/puppy-raffle/unsafe-casting)

Repo yang diaudit di video: [Cyfrin/4-puppy-raffle-audit](https://github.com/Cyfrin/4-puppy-raffle-audit). Kontrak di challenge ini **berbeda** (orisinal), jadi laporan audit PuppyRaffle tidak bisa disalin begitu saja.

### 🎮 Latihan pendamping (opsional)

Di [Ethernaut](https://ethernaut.openzeppelin.com/):

- **Coin Flip**: menebak "angka acak" yang diambil dari data blok.
- **King**: Denial of Service ketika kontrak bergantung pada pihak lain.

### 📖 Dokumentasi pendamping

| Topik | Sumber |
|---|---|
| Variabel blok (`block.timestamp`, `block.prevrandao`, `gasleft()`) | [Solidity Docs — Block and Transaction Properties](https://docs.soliditylang.org/en/latest/units-and-global-variables.html#block-and-transaction-properties) |
| Konversi tipe eksplisit (casting) | [Solidity Docs — Explicit Conversions](https://docs.soliditylang.org/en/latest/types.html#explicit-conversions) |
| Checked vs unchecked arithmetic | [Solidity Docs — Checked or Unchecked Arithmetic](https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic) |
| Cheatcode waktu & randomness | [`vm.warp`](https://getfoundry.sh/reference/cheatcodes/warp), [`vm.prevrandao`](https://getfoundry.sh/reference/cheatcodes/prevrandao) |
| Linter bawaan Foundry | [Foundry Book — Linting](https://getfoundry.sh/forge/linting) |
| Slither | [crytic/slither](https://github.com/crytic/slither), [daftar detector](https://github.com/crytic/slither/wiki/Detector-Documentation) |
| Aderyn | [Cyfrin/aderyn](https://github.com/Cyfrin/aderyn) |
| Randomness yang aman | [Chainlink VRF](https://docs.chain.link/vrf) |
| Contoh hack | [Solidity by Example — Randomness](https://solidity-by-example.org/hacks/randomness/), [Denial of Service](https://solidity-by-example.org/hacks/denial-of-service/) |

### ✅ Self-check sebelum mulai

Jawab di kepalamu. Kalau ada lebih dari dua yang belum bisa kamu jawab, tonton ulang materinya.

- [ ] Kenapa loop yang panjangnya bergantung pada input pengguna bisa menjadi Denial of Service?
- [ ] Bagaimana cara mengukur gas sebuah panggilan di dalam test Foundry?
- [ ] Siapa yang bisa memengaruhi atau mengetahui `block.timestamp`, `block.prevrandao`, dan `msg.sender` sebelum transaksi dieksekusi?
- [ ] Di Solidity ≥0.8, apa yang terjadi pada `a + b` yang overflow? Apa yang terjadi pada `uint64(x)` ketika `x` lebih besar dari `type(uint64).max`?
- [ ] Apa beda *true positive* dan *false positive* pada hasil static analysis?

---

## 🧰 Setup

Proyek Foundry sudah disiapkan, jadi kamu **tidak perlu** menjalankan `forge init`.

```bash
cd ug-challenge-4
forge build
```

Struktur folder:

```text
ug-challenge-4/
├── src/
│   └── LuckyDrawV2.sol      ← kontrak yang diaudit (JANGAN diubah)
├── test/
│   └── LuckyDrawV2.t.sol    ← kerangka test: tulis test-mu di sini
├── ANSWERS.md               ← penjelasan & jawaban per part
├── FINDINGS.md              ← laporan temuan (Part E)
├── check.sh                 ← cek mandiri
└── foundry.toml
```

Semua test ditulis di folder `test/`. Kamu boleh menambah file baru di sana.

```bash
forge test -vvv
```

### ✔️ Cek mandiri dengan `check.sh`

Benar atau tidaknya pekerjaanmu ditentukan oleh `check.sh`:

```bash
./check.sh B      # cek Part B saja
./check.sh        # cek semua part
```

**Cara kerjanya:** test milikmu dijalankan terhadap kontrak asli dan beberapa versi `LuckyDrawV2` yang masing-masing sudah **diperbaiki satu bug-nya**. PoC yang benar harus **lulus** di kontrak asli (bug-nya memang ada) dan **gagal** di versi yang bug-nya sudah diperbaiki (PoC-mu benar-benar menguji bug itu, bukan hal lain).

Contoh output:

```text
── Part B: biaya gas enter()
   ✅ Semua PoC lulus di kontrak asli (bug terbukti ada)
   ❌ Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)
```

Supaya bisa dikenali `check.sh`, **nama test wajib** mengikuti aturan berikut:

| Part | Nama fungsi |
|---|---|
| B, C, D | diawali `test_PoC_`, contoh `test_PoC_NamaBugnya()`. Satu PoC per temuan. |

> ⚠️ `check.sh` hanya mengecek **kode**. Penjelasan di `ANSWERS.md` dan `FINDINGS.md` adalah bukti bahwa kamu paham, dan menjadi bahan tanya jawab saat praktikum. Semua ✅ tetapi tidak bisa menjelaskan = belum lulus.
>
> Versi-versi kontrak pembanding disimpan dalam base64 di `.check-data` supaya tidak membocorkan jawaban. Men-decode-nya sebelum selesai sama saja dengan menyontek diri sendiri.
>
> Pengguna Windows: jalankan dari terminal **Ubuntu (WSL)**, lihat [panduan instalasi](../README.md#️-instalasi-cukup-sekali).

---

## 🔍 Kontrak yang Diaudit

| File | nSLOC | Scope |
|---|---|---|
| `src/LuckyDrawV2.sol` | 65 | ✅ In scope |

**Aktor:**

- **Pemain**: membeli tiket lewat `enter()` dan, jika menang, mengambil hadiah lewat `claimPrize()`.
- **Siapa saja**: boleh memanggil `drawWinner()` ketika sudah ada minimal 4 pemain.
- **Owner**: deployer kontrak, menerima fee lewat `withdrawFees()`.

**Ringkasan fungsi:**

| Fungsi | Perilaku yang dimaksud developer (lihat NatSpec) |
|---|---|
| `enter(address[] newPlayers)` | Mendaftarkan beberapa pemain sekaligus. Bayar tepat `entranceFee × jumlah pemain`. Alamat duplikat ditolak. |
| `drawWinner()` | Memilih pemenang secara **acak dan adil**. Pemenang mendapat 80% dari total tiket, owner 20%. Ronde direset. |
| `claimPrize()` | Pemenang menarik hadiahnya (pull payment, CEI). |
| `withdrawFees()` | Owner menarik semua fee ketika tidak ada ronde berjalan. |

Baca kodenya langsung di [`src/LuckyDrawV2.sol`](./src/LuckyDrawV2.sol). **Jangan mengubah kontrak ini.**

**`check.sh` mengecek tepat 3 temuan**, masing-masing di Part B, C, dan D. Temuan Informational/Gas (misalnya dari Slither) boleh kamu tulis di `FINDINGS.md`, tetapi tidak dicek otomatis.

### 📝 Tugas membaca (sebelum menulis kode)

Isi tabel ini di `ANSWERS.md`:

| Fungsi | State yang berubah | ETH masuk/keluar | Siapa yang boleh memanggil | Bergantung pada jumlah pemain? |
|---|---|---|---|---|
| `enter()` | ? | ? | ? | ? |
| `drawWinner()` | ? | ? | ? | ? |
| `claimPrize()` | ? | ? | ? | ? |
| `withdrawFees()` | ? | ? | ? | ? |

---

## 🅰️ Part A — Recon & Static Analysis

Auditor tidak langsung menulis exploit. Mereka mengumpulkan petunjuk dulu, termasuk dari tools otomatis.

### Tugas A1 — Compiler & linter

Jalankan:

```bash
forge build
```

Perhatikan **warning/lint** yang muncul (bukan hanya error). Salin ke `ANSWERS.md` dan jelaskan arti masing-masing dengan kata-katamu sendiri.

### Tugas A2 — Slither & Aderyn (opsional, sangat disarankan)

Kalau sudah terpasang, jalankan dari folder `ug-challenge-4`:

```bash
slither .
aderyn .
```

Untuk **setiap** temuan tool, putuskan di `ANSWERS.md`:

| Temuan tool | True positive / False positive / Informational | Alasan |
|---|---|---|
| ... | ... | ... |

Tool tidak selalu benar, dan tidak selalu lengkap. Ada bug yang **tidak** terdeteksi tool mana pun. Itulah sebabnya manual review tetap wajib.

### Tugas A3 — Manual review

Jawab di `ANSWERS.md`:

1. Bagaimana biaya gas `enter()` berubah ketika pemain ke-10 masuk, dibandingkan pemain ke-1000?
2. Siapa saja yang bisa memengaruhi atau mengetahui nilai-nilai yang dipakai `drawWinner()` untuk memilih pemenang?
3. Berapa nilai maksimum `uint64` dalam ether? Berapa pemain dengan `entranceFee = 1 ether` yang dibutuhkan agar fee satu ronde melebihi nilai itu?

Part A tidak dicek otomatis (`./check.sh A` hanya menampilkan pengingat).

---

## 🅱️ Part B — Biaya Gas `enter()`

Bayangkan undian ini viral dan ribuan orang ikut.

### Tugas B1 — Ukur

Tulis PoC `test_PoC_...` yang **membandingkan** gas yang dipakai `enter()` oleh pemain **awal** dengan gas yang dipakai pemain **belakangan**, dengan jumlah pemain per transaksi yang sama.

### Tugas B2 — Analisis

Jawab di `ANSWERS.md`:

1. Tempel angka gas yang kamu ukur. Berapa rasionya?
2. Dengan pola itu, apa yang terjadi kalau jumlah pemain terus bertambah? Kaitkan dengan **block gas limit**.
3. Siapa yang diuntungkan? Bagaimana penyerang bisa sengaja membuat pemain lain tidak mampu ikut?

> **Aturan PoC:** PoC harus **membandingkan** dua pengukuran (awal vs belakangan). Mengecek bahwa gas "lebih dari angka X" tidak membuktikan biaya yang *tumbuh*, dan tidak akan diterima `check.sh`.

<details>
<summary>💡 Hint B-1 (arah)</summary>

Cari loop di `enter()`. Berapa kali isi loop dieksekusi kalau ada `n` pemain? Apakah jumlah itu linear atau lebih buruk?

</details>

<details>
<summary>💡 Hint B-2 (konsep)</summary>

Gunakan `gasleft()` sebelum dan sesudah panggilan untuk mengukur gas ([Solidity Docs](https://docs.soliditylang.org/en/latest/units-and-global-variables.html#block-and-transaction-properties)). Tonton ulang [DoS PoC](https://updraft.cyfrin.io/courses/security/puppy-raffle/dos-poc). Untuk membuat banyak alamat unik, kamu bisa memakai `address(uint160(i))` di dalam loop.

</details>

<details>
<summary>💡 Hint B-3 (hampir jawaban)</summary>

Buat 100 alamat unik, `enter` sebagai batch pertama, dan catat gas-nya. Lalu buat 100 alamat unik **lain**, `enter` sebagai batch kedua, dan catat gas-nya. `assertGt(gasKedua, gasPertama)`. Jangan lupa membayar `entranceFee * 100` dan memberi ETH kepada pengirim dengan `vm.deal` (di `setUp` sudah disiapkan beberapa aktor).

</details>

**✔️ Cek mandiri:** `./check.sh B`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅲 Part C — Seberapa Acak `drawWinner()`?

Developer bilang pemenang dipilih "acak dan adil". Kamu adalah **penyerang** yang ikut sebagai salah satu dari 4 pemain.

### Tugas C1 — Curangi undian

Tulis PoC `test_PoC_...` yang membuat **penyerang selalu menang**.

> **Aturan PoC (wajib dipatuhi):**
> 1. PoC harus **menghitung/memprediksi** pemenang memakai rumus yang sama dengan kontrak, **sebelum** memanggil `drawWinner()`. Misalnya penyerang memilih waktu (`vm.warp`) atau alamat pemanggil sampai hasil rumusnya menunjuk ke dirinya sendiri.
> 2. Setelah `drawWinner()`, assert `raffle.lastWinner() == attacker`.
> 3. **Tidak boleh** memakai "coba-coba" dengan snapshot/revert (memanggil `drawWinner()`, melihat hasilnya, lalu membatalkan). Alasannya: cara itu hanya menunjukkan bahwa hasilnya deterministik, bukan bahwa penyerang **mengetahui rumusnya** dan bisa mengendalikan input-nya. Cara itu juga tetap "berhasil" bahkan untuk sumber acak yang aman tetapi diuji di lingkungan simulasi. `check.sh` tidak akan menerima PoC model ini.

### Tugas C2 — Analisis

Jawab di `ANSWERS.md`:

1. Untuk setiap input rumus (`msg.sender`, `block.timestamp`, `block.prevrandao`), siapa yang bisa **memilih** atau **mengetahui** nilainya sebelum transaksi dieksekusi? (pemain, validator, atau siapa saja?)
2. Kenapa fakta bahwa **siapa saja** boleh memanggil `drawWinner()` memperparah masalah ini?
3. Apa solusi yang benar? Kenapa mitigasi "menambahkan variabel blok lain ke hash" **tidak** menyelesaikan masalah?

<details>
<summary>💡 Hint C-1 (arah)</summary>

Kontrak hanya bisa melihat data yang sudah ada di blockchain, dan data itu juga bisa dilihat, bahkan dipilih, oleh pihak lain. Coba hitung sendiri rumus pemilihan pemenang di dalam test.

</details>

<details>
<summary>💡 Hint C-2 (konsep)</summary>

Tonton ulang [Exploit: Weak Randomness](https://updraft.cyfrin.io/courses/security/puppy-raffle/exploit-weak-randomness). Di Foundry, kamu bisa mengatur `block.timestamp` dengan [`vm.warp`](https://getfoundry.sh/reference/cheatcodes/warp) dan `block.prevrandao` dengan [`vm.prevrandao`](https://getfoundry.sh/reference/cheatcodes/prevrandao). Solusi yang benar dibahas di [Chainlink VRF](https://docs.chain.link/vrf).

</details>

<details>
<summary>💡 Hint C-3 (hampir jawaban)</summary>

Daftarkan 4 pemain termasuk `attacker` dan catat indeks `attacker` di array. Lalu buat loop: naikkan kandidat timestamp `t` satu per satu sampai `uint256(keccak256(abi.encodePacked(attacker, t, block.prevrandao))) % 4` sama dengan indeks attacker. Setelah ketemu, `vm.warp(t)`, lalu `vm.prank(attacker)` dan panggil `drawWinner()`.

</details>

**✔️ Cek mandiri:** `./check.sh C`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅳 Part D — Pembukuan Fee

Undian sukses besar: 100 orang ikut dalam satu ronde dengan `entranceFee = 1 ether`.

### Tugas D1 — Hitung manual dulu

Di `ANSWERS.md`, hitung dengan tangan:

- Total tiket terkumpul, hadiah pemenang (80%), dan fee owner (20%).
- Nilai maksimum yang bisa disimpan `totalFees`.

### Tugas D2 — Buktikan

Tulis PoC `test_PoC_...` yang menunjukkan bahwa `totalFees` **tidak** sama dengan fee yang seharusnya tercatat.

Jawab di `ANSWERS.md`:

1. Berapa nilai `totalFees` sebenarnya setelah ronde itu? Jelaskan dari mana angka itu berasal (tunjukkan perhitungannya).
2. Solidity ≥0.8 punya *checked arithmetic*. Kenapa transaksi ini **tidak** revert?
3. Ke mana selisih fee itu pergi? Bisakah owner atau siapa pun mengambilnya?

<details>
<summary>💡 Hint D-1 (arah)</summary>

Perhatikan tipe data `totalFees` dan baris yang menambahkan fee ke dalamnya. Berapa banyak ether yang muat di tipe itu?

</details>

<details>
<summary>💡 Hint D-2 (konsep)</summary>

Baca [Explicit Conversions](https://docs.soliditylang.org/en/latest/types.html#explicit-conversions): apa yang terjadi ketika bilangan besar dikonversi ke tipe yang lebih kecil? Bandingkan dengan [Checked or Unchecked Arithmetic](https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic). Tonton ulang [Exploit: Unsafe Casting](https://updraft.cyfrin.io/courses/security/puppy-raffle/unsafe-casting).

</details>

<details>
<summary>💡 Hint D-3 (hampir jawaban)</summary>

Daftarkan 100 alamat unik, panggil `drawWinner()`, lalu bandingkan `raffle.totalFees()` dengan `20 ether`. Nilainya akan sama dengan `20 ether - 2**64`. Untuk membuktikan dana terkunci, hitung `address(raffle).balance` dikurangi hadiah pemenang dan `totalFees`.

</details>

**✔️ Cek mandiri:** `./check.sh D`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅴 Part E — Laporan Temuan

Tulis **tiga** finding di `FINDINGS.md` menggunakan template yang tersedia:

- **Title** yang menyebut akar masalah **dan** dampaknya.
- **Severity** (Impact × Likelihood) beserta alasannya.
- **Description**, **Impact**, **Proof of Concept** (tempel test PoC-mu), dan **Recommended Mitigation** (dalam bentuk `diff`).

Pertanyaan yang perlu kamu jawab di laporan:

- Untuk DoS: apakah mitigasinya cukup dengan "membatasi jumlah pemain"? Bandingkan dengan memakai `mapping`.
- Untuk randomness: mengapa Chainlink VRF (atau commit-reveal) lebih baik daripada hash data blok?
- Untuk unsafe casting: mengapa mitigasi terbaik adalah mengganti tipe `totalFees` menjadi `uint256`, bukan sekadar menambahkan `require` sebelum cast?

Temuan tambahan (Informational/Gas dari Part A) boleh ditulis dengan ID `I-xx` / `G-xx`.

Part E tidak dicek otomatis.

---

## 🏁 Kriteria Keberhasilan

| Part | Kriteria | Bukti |
|---|---|---|
| A | Hasil compiler/Slither/Aderyn dipilah dengan alasan yang benar. | Tabel triase di `ANSWERS.md` |
| B | DoS terbukti dengan membandingkan gas pemain awal vs belakangan. | `./check.sh B` ✅ + angka gas |
| C | Penyerang terbukti bisa memilih dirinya sebagai pemenang dengan memprediksi rumus. | `./check.sh C` ✅ + analisis input |
| D | Fee yang terpotong diam-diam terbukti dan dijelaskan perhitungannya. | `./check.sh D` ✅ + hitungan manual |
| E | Tiga finding ditulis lengkap dengan severity dan mitigasi. | `FINDINGS.md` |

Tidak perlu menyelesaikan semuanya sekaligus. Satu part, satu `./check.sh`, lalu lanjut.

---

## 🚀 Mulai Sekarang

1. Tonton materi **Part 0** di Cyfrin Updraft.
2. Isi **Tabel Fungsi** dan kerjakan **Part A** di `ANSWERS.md`.
3. Kerjakan **Part B**, lalu jalankan `./check.sh B`.
4. Semua ✅? Lanjut ke Part C, dan seterusnya.

Target akhirnya: kamu terbiasa memadukan **tools otomatis** dan **manual review**, lalu membuktikan setiap temuan dengan PoC yang tepat sasaran, **tanpa bergantung pada AI**.
