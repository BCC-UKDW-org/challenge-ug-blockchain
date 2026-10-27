# Challenge 01 — Vault Invariant Hunter

| | |
|---|---|
| **Level** | Beginner → Intermediate |
| **Basis materi** | [Cyfrin Updraft — Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **Review** (Fuzzing & Invariants) |
| **Tools** | Solidity, Foundry (Forge) |
| **Estimasi waktu** | Menonton materi 2–8 jam (tergantung jalur) + mengerjakan 45–90 menit per part |
| **Fokus** | Stateless fuzzing, stateful fuzzing, invariant, handler, reentrancy, menulis laporan audit |
| **Cek jawaban** | `./check.sh` (lihat [Cek mandiri](#️-cek-mandiri-dengan-checksh)) |

> ⚠️ **Sebelum mulai, baca [Aturan Utama](../../README.md#️-aturan-utama--wajib-dibaca).**
> AI hanya boleh dipakai seperti Google, yaitu untuk mencari dokumentasi dan konsep. **Kode, penjelasan, dan laporan harus kamu tulis sendiri.**

---

## 🎯 Misi Kamu

Kamu diminta mengaudit smart contract bernama `SimpleVault`.

Vault ini memungkinkan pengguna:

- Menyetorkan ETH.
- Menarik ETH.
- Memeriksa saldo ETH yang tercatat atas nama mereka.

Developer mengklaim bahwa *"vault ini aman dan pembukuannya selalu benar."*

**Tugasmu adalah membuktikan apakah klaim itu benar atau salah, dengan test, bukan dengan opini.**

### Setelah menyelesaikan challenge ini, kamu akan bisa:

1. Membedakan **unit test**, **stateless fuzz test**, dan **stateful fuzz (invariant) test**.
2. Merumuskan **invariant** dari sebuah kontrak dalam bentuk persamaan.
3. Membangun **handler** agar fuzzer menguji skenario yang realistis.
4. Membaca **call sequence** dari Foundry ketika invariant dilanggar.
5. Menganalisis **reentrancy** berdasarkan urutan eksekusi, bukan berdasarkan pola semata.
6. Menulis **finding** dengan format laporan audit profesional.

---

## 📺 Part 0 — Wajib Tonton Cyfrin Updraft Dulu

Challenge ini dibangun di atas materi **Cyfrin Updraft**. Tonton dulu materinya **sebelum** membuka soal. Tanpa konteks dari video, challenge ini akan terasa mustahil, dan kamu akan tergoda menyuruh AI mengerjakannya.

### ✅ Wajib (semua peserta)

Section **Review** dari course [Smart Contract Security](https://updraft.cyfrin.io/courses/security):

- [ ] [Tooling Prerequisites](https://updraft.cyfrin.io/courses/security/review/tooling-requisites)
- [ ] [Solidity Prerequisites](https://updraft.cyfrin.io/courses/security/review/solidity-requisites)
- [ ] ⭐ [Fuzzing and Invariants](https://updraft.cyfrin.io/courses/security/review/fuzzing-and-invariants)
- [ ] [Fallback and Receive](https://updraft.cyfrin.io/courses/security/review/fallback-and-receive) (dibutuhkan untuk Part D)

### 🟢 Belum pernah memakai Solidity atau Foundry? Tonton ini dulu

| # | Course | Yang harus kamu kuasai |
|---|---|---|
| 1 | [Solidity Smart Contract Development](https://updraft.cyfrin.io/courses/solidity) | `mapping`, `msg.sender`, `msg.value`, `payable`, `require` |
| 2 | [Foundry Fundamentals](https://updraft.cyfrin.io/courses/foundry) | `forge test`, struktur test, `setUp()`, cheatcodes |

### 📖 Dokumentasi pendamping (dipakai saat mengerjakan)

| Topik | Sumber |
|---|---|
| Fuzz testing di Foundry | [Foundry Book — Fuzz Testing](https://getfoundry.sh/forge/fuzz-testing) |
| Invariant testing & handler | [Foundry Book — Invariant Testing](https://getfoundry.sh/forge/invariant-testing) |
| Cheatcodes (`vm.prank`, `vm.deal`, ...) | [Foundry Book — Cheatcodes](https://getfoundry.sh/reference/cheatcodes/overview) |
| Membatasi input fuzz | [forge-std — `bound()`](https://getfoundry.sh/reference/forge-std/bound) |
| Artikel fuzzing & invariant | [Cyfrin Blog](https://www.cyfrin.io/blog/smart-contract-fuzzing-and-invariants-testing-foundry), [RareSkills](https://rareskills.io/post/invariant-testing-solidity) |
| Reentrancy & CEI | [Solidity by Example](https://solidity-by-example.org/hacks/re-entrancy/), [Solidity Docs — Security Considerations](https://docs.soliditylang.org/en/latest/security-considerations.html) |
| Source `StdInvariant.sol` | [forge-std](https://github.com/foundry-rs/forge-std/blob/master/src/StdInvariant.sol) |

### ✅ Self-check sebelum mulai

Jawab di kepalamu. Kalau ada lebih dari dua yang belum bisa kamu jawab, tonton ulang materinya.

- [ ] Apa beda **fuzz test** dan **unit test**?
- [ ] Apa itu **invariant**? Beri satu contoh dari kehidupan sehari-hari (misalnya pembukuan kas).
- [ ] Apa beda **stateless** dan **stateful** fuzzing?
- [ ] Apa yang dilakukan `vm.prank(alice)`? Berlaku untuk berapa panggilan?
- [ ] Bagaimana cara mengirim ETH ke fungsi `payable` dari dalam test?
- [ ] Mengapa `bound()` sering lebih baik daripada `vm.assume()`?
- [ ] Apa itu **reentrancy**, dan apa urutan **Checks-Effects-Interactions**?

---

## 🧰 Setup

Proyek Foundry sudah disiapkan, jadi kamu **tidak perlu** menjalankan `forge init`.

```bash
cd ug-challenge/ug-challenge-1   # dari folder utama repo
forge build
```

Struktur folder:

```text
ug-challenge-1/
├── src/
│   └── SimpleVault.sol      ← kontrak yang diaudit (JANGAN diubah)
├── test/
│   └── SimpleVault.t.sol    ← kerangka test: tulis test-mu di sini
├── ANSWERS.md               ← penjelasan & jawaban per part
├── FINDINGS.md              ← laporan bug (Part D)
├── check.sh                 ← cek mandiri
└── foundry.toml
```

Semua test ditulis di folder `test/`. Kamu boleh menambah file baru di sana, misalnya `test/Handler.sol` atau `test/Attacker.sol`.

```bash
forge test -vvv
```

### ✔️ Cek mandiri dengan `check.sh`

Benar atau tidaknya pekerjaanmu ditentukan oleh `check.sh`:

```bash
./check.sh A      # cek Part A saja
./check.sh        # cek semua part
```

**Cara kerjanya:** test milikmu dijalankan terhadap beberapa versi `SimpleVault`, yaitu versi asli, versi yang sudah diperbaiki, dan beberapa versi yang **sengaja dirusak** (*mutation testing*). Test yang baik harus **lulus** di versi yang benar dan **gagal** di versi yang rusak. Test yang tetap hijau padahal kontraknya dirusak berarti tidak menguji apa-apa.

Contoh output:

```text
── Part A: testFuzz_Deposit
   ✅ Lulus di kontrak asli (input nol & input besar sudah ditangani)
   ✅ Mendeteksi deposit yang lupa menambah totalDeposits
   ❌ Mendeteksi deposit yang mencatat saldo pengguna dengan salah
```

Supaya bisa dikenali `check.sh`, **nama test wajib** mengikuti aturan berikut:

| Part | Nama fungsi |
|---|---|
| A | `testFuzz_Deposit(uint96)` |
| B, C | `invariant_AccountingIsConsistent()` |
| D1 | diawali `test_PoC_`, contoh `test_PoC_NamaBugnya()` |
| D2 | diawali `test_Reentrancy`, contoh `test_ReentrancyAttack()` |

> ⚠️ `check.sh` hanya mengecek **kode**. Penjelasan di `ANSWERS.md` dan `FINDINGS.md` adalah bukti bahwa kamu paham, dan tim BCC UKDW bisa memintamu menjelaskannya kapan saja. Semua ✅ tetapi tidak bisa menjelaskan = belum lulus.
>
> Versi-versi kontrak pembanding disimpan dalam base64 di `.check-data` supaya tidak membocorkan jawaban. Men-decode-nya sebelum selesai sama saja dengan menyontek diri sendiri.
>
> Pengguna Windows: jalankan dari terminal **Ubuntu (WSL)**, lihat [panduan instalasi](../../README.md#️-instalasi-cukup-sekali).

---

## 🔍 Kontrak yang Diaudit

File: [`src/SimpleVault.sol`](./src/SimpleVault.sol)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleVault {
    mapping(address => uint256) public balances;

    uint256 public totalDeposits;

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");

        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }
}
```

**Jangan mengubah kontrak ini.** Posisikan dirimu sebagai auditor eksternal yang hanya boleh membaca dan menguji, bukan mengedit source code protokol.

Ada dua variabel state yang penting:

- `balances` mencatat saldo setiap pengguna.
- `totalDeposits` mencatat total deposit yang diterima kontrak.

Ada sesuatu yang perlu kamu periksa pada **hubungan antara kedua variabel tersebut**. Letak masalahnya sengaja tidak ditunjukkan.

### 📝 Tugas membaca (sebelum menulis kode)

Isi tabel ini di `ANSWERS.md`. Auditor selalu memetakan efek setiap fungsi terhadap state sebelum menulis test.

| Fungsi | `balances[msg.sender]` | `totalDeposits` | ETH di kontrak | External call? |
|---|---|---|---|---|
| `deposit()` | ? | ? | ? | ? |
| `withdraw(amount)` | ? | ? | ? | ? |

---

## 🅰️ Part A — Stateless Fuzzing

### Tugas A1 — Fuzz test `deposit()`

Di `test/SimpleVault.t.sol`, buat:

```solidity
function testFuzz_Deposit(uint96 amount) public {
    // Implementasikan sendiri
}
```

**Persyaratan:**

1. Gunakan `vm.prank(alice)` untuk melakukan deposit sebagai Alice.
2. Kirim ETH sejumlah `amount` ke fungsi `deposit()`.
3. Pastikan saldo Alice di vault bertambah sesuai jumlah deposit.
4. Pastikan `totalDeposits` juga bertambah sesuai jumlah deposit.
5. Tangani input **nol** dan input yang **melebihi saldo ETH Alice** (100 ether).

**Bonus A1:** buat `testFuzz_DepositZeroReverts()` atau test serupa yang membuktikan deposit `0` memang revert dengan pesan yang tepat (gunakan `vm.expectRevert`).

### Tugas A2 — Jalankan & analisis

```bash
forge test --match-test testFuzz_Deposit -vvv
```

Jawab di `ANSWERS.md`:

1. Apakah semua input menghasilkan hasil yang benar?
2. Coba **hapus** penanganan input nol dan input besar, lalu jalankan ulang. Input apa yang ditemukan fuzzer? Tempel output-nya.
3. Jika ada transaksi yang revert, apakah itu berarti kontraknya rentan? Jelaskan perbedaan **revert yang diharapkan** dan **bug**.
4. Mengapa tipe parameternya `uint96`, bukan `uint256`? Berapa nilai maksimum `uint96` dalam ether?
5. Kenapa kamu memilih assertion yang kamu tulis?

> Jangan hanya mengejar test hijau. Test hijau yang tidak menguji apa-apa lebih berbahaya daripada test merah.

<details>
<summary>💡 Hint A-1 (arah)</summary>

Ada dua kelompok input yang membuat `deposit` gagal, dan **keduanya bukan bug di vault**. Satu ditolak oleh `require` di kontrak, satu lagi gagal karena Alice tidak punya cukup ETH. Test kamu perlu "membuang" atau "menjepit" input semacam itu.

</details>

<details>
<summary>💡 Hint A-2 (konsep)</summary>

Baca [`bound()`](https://getfoundry.sh/reference/forge-std/bound) dan bandingkan dengan `vm.assume()` di [Foundry Book — Fuzz Testing](https://getfoundry.sh/forge/fuzz-testing). Mana yang membuang banyak run, dan mana yang mempertahankan run? Untuk sintaks mengirim ETH, cari "function call options `{value: ...}`" di dokumentasi Solidity.

</details>

<details>
<summary>💡 Hint A-3 (hampir jawaban)</summary>

Jepit `amount` ke rentang `[1, 100 ether]` dengan `bound`. Perhatikan bahwa `bound` mengembalikan `uint256`, sementara variabelmu `uint96`. Setelah itu: prank sebagai Alice, panggil `deposit{value: ...}()`, lalu dua `assertEq`, masing-masing untuk `balances(alice)` dan `totalDeposits()`.

</details>

**✔️ Cek mandiri:** `./check.sh A`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅱️ Part B — Temukan Invariant

> **Invariant** adalah aturan yang **harus selalu benar**, apa pun urutan dan jumlah transaksi yang terjadi.

### Tugas B1 — Rumuskan invariant (tanpa kode)

Jawab di `ANSWERS.md` **sebelum** menulis kode:

> Jika Alice dan Bob adalah satu-satunya pengguna vault, bagaimana hubungan antara `balances[alice]`, `balances[bob]`, dan `totalDeposits`?

Tulis dalam bentuk persamaan, misalnya:

```text
Invariant 1: balances[alice] + balances[bob] == totalDeposits
```

Lalu pikirkan:

- Apakah persamaan itu **seharusnya** benar menurut niat developer?
- Telusuri setiap fungsi menggunakan tabel di bagian "Tugas membaca". Apakah persamaan itu **benar-benar** bertahan setelah setiap fungsi dipanggil?
- Bisakah kamu merumuskan **invariant kedua** yang melibatkan saldo ETH kontrak (`address(vault).balance`)?

### Tugas B2 — Implementasi invariant test

`Test` dari forge-std **sudah mewarisi** `StdInvariant`, jadi fungsi seperti `targetContract()` langsung tersedia.

```solidity
contract SimpleVaultTest is Test {
    // ...

    function invariant_AccountingIsConsistent() public view {
        // Implementasikan invariant kamu
    }
}
```

> 🧪 **Eksperimen kecil:** coba ubah deklarasinya menjadi `contract SimpleVaultTest is Test, StdInvariant` (dengan meng-import `StdInvariant`). Error apa yang muncul, dan mengapa? Cari di [Solidity Docs — Multiple Inheritance and Linearization](https://docs.soliditylang.org/en/latest/contracts.html#multiple-inheritance-and-linearization). Tulis penjelasannya di `ANSWERS.md`, lalu kembalikan ke `is Test`.

Pertama, coba versi paling naif: di `setUp()`, daftarkan `targetContract(address(vault))`, lalu jalankan:

```bash
forge test --match-test invariant_ -vvv
```

Jawab di `ANSWERS.md`:

1. Apakah test-nya **lulus**? Apakah kamu **percaya** hasilnya?
2. Siapa `msg.sender` yang dipakai fuzzer saat memanggil vault? Apakah mereka Alice atau Bob? Apakah mereka punya ETH?
3. Jalankan dengan `-vvvv` dan lihat berapa banyak panggilan yang **revert**. Apa artinya bagi kualitas pengujianmu?

<details>
<summary>💡 Hint B-1 (arah)</summary>

Test invariant yang lulus belum tentu berarti kontraknya benar. Bisa jadi fuzzer **tidak pernah berhasil melakukan apa-apa**. Kalau hampir semua panggilan revert, state tidak pernah berubah, sehingga invariant "aman" secara kebetulan.

</details>

<details>
<summary>💡 Hint B-2 (konsep)</summary>

Baca bagian *target contracts*, *target senders*, dan *handler-based testing* di [Foundry Book — Invariant Testing](https://getfoundry.sh/forge/invariant-testing). Perhatikan pula opsi `fail_on_revert` di `foundry.toml`.

</details>

**✔️ Cek mandiri:** `./check.sh B`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅲 Part C — Stateful Fuzzing dengan Handler

Sekarang kita menguji **urutan operasi**, bukan satu pemanggilan. Contoh:

```text
Alice deposit 10 ETH  →  Bob deposit 5 ETH  →  Alice withdraw 3 ETH  →  Bob withdraw 2 ETH  →  cek invariant
```

Urutan di atas hanya ilustrasi. Fuzzer akan mencoba **ribuan** urutan dan jumlah ETH yang berbeda.

### Masalah: fuzzing tanpa arah

Dengan `targetContract(address(vault))` saja, fuzzer memanggil vault dari alamat acak tanpa ETH dan dengan jumlah acak. Sebagian besar panggilan revert, sehingga skenario yang benar-benar ingin kamu uji (Alice dan Bob) hampir tidak pernah terjadi.

### Solusi: handler

**Handler** adalah kontrak perantara yang menyediakan aksi-aksi "masuk akal" untuk fuzzer:

```text
 Fuzzer  ──►  Handler.deposit(seed, amount)   ──►  pilih Alice/Bob, jepit amount  ──►  vault.deposit()
         ──►  Handler.withdraw(seed, amount)  ──►  pilih Alice/Bob, jepit amount  ──►  vault.withdraw()
```

Kerangka minimal (lengkapi sendiri):

```solidity
contract Handler is Test {
    SimpleVault vault;
    // simpan daftar aktor di sini

    constructor(/* ... */) {
        // ...
    }

    function deposit(uint256 actorSeed, uint256 amount) external {
        // 1. pilih aktor dari seed
        // 2. jepit amount ke rentang yang valid
        // 3. prank sebagai aktor, lalu deposit
    }

    function withdraw(uint256 actorSeed, uint256 amount) external {
        // 1. pilih aktor dari seed
        // 2. kalau saldonya nol, apa yang sebaiknya dilakukan?
        // 3. jepit amount agar tidak melebihi saldo aktor
        // 4. prank sebagai aktor, lalu withdraw
    }
}
```

### Tugas C1 — Implementasi handler

Handler harus memenuhi syarat berikut:

- Alice dan Bob bisa melakukan deposit dan withdraw.
- Jumlah deposit tidak melebihi ETH yang dimiliki aktor.
- Jumlah withdraw tidak melebihi saldo aktor di vault.
- Tidak ada panggilan yang sia-sia (revert karena input tidak valid).

### Tugas C2 — Jalankan & investigasi

Ubah `setUp()` agar menargetkan **handler**, bukan vault. Lalu jalankan:

```bash
forge test --match-test invariant_ -vvv
```

Jawab di `ANSWERS.md`:

1. Apakah hasilnya berbeda dari Part B? Mengapa?
2. Kalau invariant **gagal**, jangan panik. Tempel **call sequence** yang ditampilkan Foundry, lalu jelaskan langkah demi langkah apa yang terjadi pada state.
3. Kegagalan ini disebabkan **bug di test-mu** atau **bug di kontrak**? Buktikan.
4. Bandingkan Invariant 1 dan Invariant 2 dari Part B. Mana yang dilanggar, dan mana yang tetap bertahan? Apa artinya?

<details>
<summary>💡 Hint C-1 (arah)</summary>

Untuk memilih aktor dari angka acak, gunakan operasi modulo terhadap jumlah aktor. Saat saldo aktor nol (ETH di dompet untuk deposit, atau saldo di vault untuk withdraw), `return` lebih awal lebih baik daripada membiarkannya revert. Coba pikirkan: apa yang terjadi pada `bound(x, 1, 0)`?

</details>

<details>
<summary>💡 Hint C-2 (konsep)</summary>

Handler perlu tahu alamat vault dan para aktor, jadi berikan lewat constructor. Di `setUp()`, deploy handler lalu daftarkan dengan `targetContract(address(handler))`. Kalau mau lebih rapi, pelajari juga `targetSelector` untuk membatasi fungsi handler yang boleh dipanggil fuzzer.

</details>

<details>
<summary>💡 Hint C-3 (hampir jawaban)</summary>

Di handler, `actor = actors[actorSeed % actors.length]`. Untuk deposit, `amount = bound(amount, 1, actor.balance)`. Untuk withdraw, ambil `vault.balances(actor)`; jika `0` maka `return`, jika tidak `amount = bound(amount, 1, saldo)`. Kemudian `vm.prank(actor)` dan panggil vault. Perhatikan: `vm.prank` hanya berlaku untuk **satu panggilan eksternal berikutnya**, termasuk panggilan *view* seperti `vault.balances(...)`. Jadi letakkan `vm.prank` **tepat sebelum** `deposit`/`withdraw`.

</details>

**🌟 Bonus C — Ghost variables:** tambahkan variabel di handler seperti `ghost_totalDeposited` dan `ghost_totalWithdrawn` yang mencatat apa yang **seharusnya** terjadi. Tulis invariant yang membandingkan nilai ghost dengan state vault. Apa kelebihan pendekatan ini?

**✔️ Cek mandiri:** `./check.sh C`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅳 Part D — Security Researcher Mode

Sekarang kamu bukan lagi sekadar penulis test, tetapi auditor. Jawab tiga pertanyaan di bawah. **Jangan langsung mencari jawabannya di internet.** Buktikan dengan test.

### Pertanyaan D1 — Accounting

Bandingkan `withdraw()` dengan `deposit()`.

**Apakah semua variabel accounting diperbarui secara konsisten ketika pengguna menarik dana?**

Jika tidak:

1. Tulis **finding** lengkap di `FINDINGS.md` menggunakan template yang tersedia.
2. Sertakan **PoC berupa test** (unit test sederhana *dan* invariant dari Part C).
3. Jelaskan **dampaknya**. Bayangkan ada kontrak lain, frontend, atau sistem reward yang bergantung pada `totalDeposits`. Apa yang bisa salah?
4. Tentukan **severity** (High/Medium/Low/Informational) beserta alasannya.

### Pertanyaan D2 — Reentrancy

`withdraw()` menggunakan:

```solidity
(bool success, ) = payable(msg.sender).call{value: amount}("");
```

Pemanggilan ini mengirim ETH sekaligus **menjalankan kode di alamat penerima** (jika penerimanya kontrak).

1. Apakah kontrak penyerang bisa memanggil kembali `withdraw()` di dalam `receive()` saat transfer sedang berlangsung?
2. Jika bisa, apakah urutan perubahan state di `withdraw()` cukup untuk mencegah penarikan berlebih?
3. **Buktikan dengan test:** tulis kontrak `Attacker` yang mencoba reentrancy, lalu tunjukkan hasilnya (berhasil mencuri, atau gagal dan mengapa).

> Jangan langsung menyimpulkan bahwa setiap `.call{value: ...}` pasti rentan. Analisis **urutan eksekusinya**: kapan *check*, kapan *effect*, dan kapan *interaction* terjadi?

### Pertanyaan D3 — Batas invariant testing

Misalkan semua test kamu lulus. **Apakah itu membuktikan kontrak bebas dari semua kerentanan?**

Jelaskan **minimal dua alasan** mengapa invariant testing yang lulus belum tentu membuktikan keamanan kontrak. Kaitkan dengan pengalamanmu di Part B (test naif yang lulus).

<details>
<summary>💡 Hint D-1 (arah)</summary>

Untuk D1: hitung berapa variabel yang berubah di `deposit()` dan berapa yang berubah di `withdraw()`. Untuk D3: pikirkan apa yang *tidak* diuji oleh invariant-mu, seperti aktor lain, fungsi lain, atau properti lain yang tidak kamu tulis.

</details>

<details>
<summary>💡 Hint D-2 (konsep)</summary>

Untuk D2: baca pola Checks-Effects-Interactions di [Solidity Docs — Security Considerations](https://docs.soliditylang.org/en/latest/security-considerations.html), lalu bandingkan dengan contoh kontrak rentan di [Solidity by Example](https://solidity-by-example.org/hacks/re-entrancy/). Apa perbedaan urutan baris kodenya dengan `SimpleVault`?

</details>

<details>
<summary>💡 Hint D-3 (hampir jawaban)</summary>

Kontrak `Attacker` cukup berisi: fungsi `attack()` yang melakukan deposit lalu withdraw, dan `receive()` yang memanggil `withdraw` lagi selama vault masih punya ETH. Di test, isi vault dengan deposit Bob, jalankan serangan, lalu bandingkan saldo sebelum dan sesudah. Perhatikan pesan revert yang muncul di trace `-vvvv`: dari `require` mana asalnya?

</details>

**✔️ Cek mandiri:** `./check.sh D`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🏁 Kriteria Keberhasilan

| Part | Kriteria | Bukti |
|---|---|---|
| A | Fuzz test deposit memeriksa saldo dan total deposit, serta menangani input nol dan input besar dengan benar. | Test hijau + penjelasan revert vs bug |
| B | Invariant accounting dirumuskan dengan benar, dan kamu bisa menjelaskan mengapa test naif menipu. | Persamaan + analisis revert |
| C | Handler membuat fuzzing terarah, dan kamu bisa membaca call sequence yang melanggar invariant. | Call sequence + penjelasan langkah demi langkah |
| D1 | Inkonsistensi accounting ditemukan dan dilaporkan dengan format profesional. | `FINDINGS.md` + PoC |
| D2 | Reentrancy dianalisis dan **dibuktikan** dengan test `Attacker`. | Test + penjelasan CEI |
| D3 | Keterbatasan invariant testing dijelaskan dengan minimal dua alasan. | Jawaban di `ANSWERS.md` |

Tidak perlu menyelesaikan semuanya sekaligus. Satu part, satu `./check.sh`, lalu lanjut.

---

## 🚀 Mulai Sekarang

1. Tonton materi **Part 0** di Cyfrin Updraft.
2. Isi **Tabel Fungsi** di `ANSWERS.md`.
3. Kerjakan **Part A**, lalu jalankan `./check.sh A`.
4. Semua ✅? Lanjut ke Part B, dan seterusnya.

Target akhirnya: kamu mampu menulis invariant test sendiri dan memahami cara security researcher menggunakan Foundry untuk menemukan bug, **tanpa bergantung pada AI**.
