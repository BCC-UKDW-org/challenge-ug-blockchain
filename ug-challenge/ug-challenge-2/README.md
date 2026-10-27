# Challenge 02 — Secret Keeper

| | |
|---|---|
| **Level** | Beginner |
| **Basis materi** | [Cyfrin Updraft — Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **Your First Audit \| PasswordStore** |
| **Tools** | Solidity, Foundry (Forge) |
| **Estimasi waktu** | Menonton materi ±2–3 jam + mengerjakan 60–90 menit |
| **Fokus** | Recon & scoping, access control, data `private` di storage, property test, menulis finding & severity |
| **Cek jawaban** | `./check.sh` (lihat [Cek mandiri](#️-cek-mandiri-dengan-checksh)) |

> ⚠️ **Sebelum mulai, baca [Aturan Utama](../../README.md#️-aturan-utama--wajib-dibaca).**
> AI hanya boleh dipakai seperti Google, yaitu untuk mencari dokumentasi dan konsep. **Kode, penjelasan, dan laporan harus kamu tulis sendiri.**

---

## 🎯 Misi Kamu

Sebuah tim membuat `SecretKeeper`, kontrak "brankas rahasia" pribadi. Owner menyimpan sebuah secret (misalnya kata sandi) di blockchain supaya bisa diambil kapan saja.

Developer mengklaim:

> *"Hanya owner yang bisa melihat dan mengganti secret. Variabelnya sudah kami beri `private`, jadi aman."*

Ini audit pertamamu. Kontraknya kecil, tetapi justru di sini kamu belajar **proses** audit: membaca dokumentasi, memetakan aktor, mencurigai setiap klaim, membuktikan dengan test, lalu menulis laporan yang bisa dipahami developer.

### Setelah menyelesaikan challenge ini, kamu akan bisa:

1. Melakukan **scoping** dan **recon** sederhana: aktor, fungsi, dan storage layout.
2. Membandingkan **perilaku kode** dengan **klaim di dokumentasi/NatSpec**.
3. Menulis **property test** (fuzz) untuk access control.
4. Membaca storage kontrak secara langsung dengan `vm.load`.
5. Menulis **finding** lengkap dan menentukan **severity** dengan matriks Impact × Likelihood.

---

## 📺 Part 0 — Wajib Tonton Cyfrin Updraft Dulu

Challenge ini dibangun di atas materi **Cyfrin Updraft**. Tonton dulu materinya **sebelum** membuka soal.

### ✅ Wajib

Section **What is a Smart Contract Audit** dan **Your First Audit | PasswordStore** dari course [Smart Contract Security](https://updraft.cyfrin.io/courses/security):

- [ ] [What is a Smart Contract Audit?](https://updraft.cyfrin.io/courses/security/audit/what-is-an-audit)
- [ ] [The Audit Process](https://updraft.cyfrin.io/courses/security/audit/the-audit)
- [ ] [Your First Security Review](https://updraft.cyfrin.io/courses/security/first-audit/first-review)
- [ ] [Recon: Understanding the Code](https://updraft.cyfrin.io/courses/security/first-audit/understanding-the-code)
- [ ] ⭐ [Exploit: Access Control](https://updraft.cyfrin.io/courses/security/first-audit/access-control)
- [ ] ⭐ [Exploit: Public Data](https://updraft.cyfrin.io/courses/security/first-audit/exploit-public-data)
- [ ] [Protocol Tests](https://updraft.cyfrin.io/courses/security/first-audit/protocol-tests)
- [ ] ⭐ [Writing an Amazing Finding](https://updraft.cyfrin.io/courses/security/first-audit/finding-report)
- [ ] [Writing an Amazing Finding: Proof of Code](https://updraft.cyfrin.io/courses/security/first-audit/proof-of-code)
- [ ] [Writing an Amazing Finding: Recommended Mitigation](https://updraft.cyfrin.io/courses/security/first-audit/recommended-mitigation)
- [ ] [Severity Rating Introduction](https://updraft.cyfrin.io/courses/security/first-audit/severity-rating-introduction)
- [ ] [Assessing Highs](https://updraft.cyfrin.io/courses/security/first-audit/assesing-highs)
- [ ] [Storage](https://updraft.cyfrin.io/courses/security/review/storage) (section Review)

Repo yang dibahas di video: [Cyfrin/3-passwordstore-audit](https://github.com/Cyfrin/3-passwordstore-audit). Kontrak di challenge ini **berbeda**, jadi jangan menyalin laporan dari sana. Pahami polanya.

### 🎮 Latihan pendamping (opsional)

- [Ethernaut](https://ethernaut.openzeppelin.com/) level **Vault**.

### 📖 Dokumentasi pendamping

| Topik | Sumber |
|---|---|
| Membaca storage dari test | [Foundry Book — `vm.load`](https://getfoundry.sh/reference/cheatcodes/load) |
| Mengecualikan input fuzz | [Foundry Book — `vm.assume`](https://getfoundry.sh/reference/cheatcodes/assume) |
| Mengharapkan revert | [Foundry Book — `vm.expectRevert`](https://getfoundry.sh/reference/cheatcodes/expect-revert) |
| Layout storage & cara `string` disimpan | [Solidity Docs — Layout of State Variables in Storage](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html#bytes-and-string) |
| Custom error | [Solidity Docs — Errors and the Revert Statement](https://docs.soliditylang.org/en/latest/contracts.html#errors-and-the-revert-statement) |
| Melihat storage layout | jalankan `forge inspect SecretKeeper storageLayout` |

### ✅ Self-check sebelum mulai

- [ ] Apa saja fase audit (scoping, recon, identifikasi, reporting)?
- [ ] Apa arti kata kunci `private` di Solidity? Apakah artinya "rahasia"?
- [ ] Bagaimana kontrak memeriksa siapa pemanggilnya?
- [ ] Apa beda **Impact** dan **Likelihood**?
- [ ] Apa saja bagian dari sebuah finding yang baik?

---

## 🧰 Setup

```bash
cd ug-challenge/ug-challenge-2   # dari folder utama repo
forge build
```

Struktur folder:

```text
ug-challenge-2/
├── src/
│   └── SecretKeeper.sol      ← kontrak yang diaudit (JANGAN diubah)
├── test/
│   └── SecretKeeper.t.sol    ← kerangka test: tulis test-mu di sini
├── ANSWERS.md                ← jawaban & penjelasan per part
├── FINDINGS.md               ← laporan temuan (Part D)
├── check.sh                  ← cek mandiri
└── foundry.toml
```

Semua test ditulis di folder `test/`. Jalankan dengan:

```bash
forge test -vvv
```

### ✔️ Cek mandiri dengan `check.sh`

```bash
./check.sh B      # cek Part B saja
./check.sh        # cek semua part
```

**Cara kerjanya:** test milikmu dijalankan terhadap kontrak asli dan versi kontrak yang **sudah diperbaiki**. PoC yang benar harus **lulus** di kontrak asli (bug terbukti ada) dan **gagal** ketika bug itu diperbaiki. Property test yang benar justru sebaliknya: **gagal** di kontrak asli dan **lulus** di versi yang benar.

Contoh output:

```text
── Part C: test_PoC_*
   ✅ Semua PoC lulus di kontrak asli (bug terbukti ada)
   ✅ Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)
   ❌ Temuan #2 terbukti (...)
```

Supaya bisa dikenali `check.sh`, **nama test wajib** mengikuti aturan berikut:

| Part | Nama fungsi |
|---|---|
| B | `testFuzz_NonOwnerCannotSetSecret(address)` |
| C | diawali `test_PoC_`, contoh `test_PoC_NamaBugnya()`. Boleh lebih dari satu. |

> ⚠️ `check.sh` hanya mengecek **kode**. Penjelasan di `ANSWERS.md` dan `FINDINGS.md` adalah bukti bahwa kamu paham, dan tim BCC UKDW bisa memintamu menjelaskannya kapan saja. Semua ✅ tetapi tidak bisa menjelaskan = belum lulus.
>
> Versi-versi kontrak pembanding disimpan dalam base64 di `.check-data` supaya tidak membocorkan jawaban. Men-decode-nya sebelum selesai sama saja dengan menyontek diri sendiri.
>
> Pengguna Windows: jalankan dari terminal **Ubuntu (WSL)**, lihat [panduan instalasi](../../README.md#️-instalasi-cukup-sekali).

---

## 🔍 Kontrak yang Diaudit

| File | nSLOC | Scope |
|---|---|---|
| `src/SecretKeeper.sol` | ±20 | ✅ In scope |

**Aktor:**

- **Owner:** yang men-deploy kontrak. Satu-satunya yang boleh mengganti dan membaca secret.
- **Pengguna lain:** siapa pun selain owner. Menurut dokumentasi, tidak boleh mengganti maupun melihat secret.

File: [`src/SecretKeeper.sol`](./src/SecretKeeper.sol)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecretKeeper
/// @notice Brankas sederhana untuk menyimpan satu secret milik owner, misalnya PIN atau kata sandi.
/// @dev Klaim developer:
///      1. Hanya owner yang boleh mengganti secret.
///      2. Hanya owner yang bisa melihat secret.
contract SecretKeeper {
    error SecretKeeper__NotOwner();

    address private s_owner;
    string private s_secret;

    event SecretUpdated();

    constructor() {
        s_owner = msg.sender;
    }

    /// @notice Mengganti secret. Hanya owner yang boleh memanggil fungsi ini.
    /// @param newSecret Secret baru.
    function setSecret(string calldata newSecret) external {
        s_secret = newSecret;
        emit SecretUpdated();
    }

    /// @notice Mengembalikan secret. Hanya owner yang boleh memanggil fungsi ini.
    /// @return Secret yang tersimpan.
    function getSecret() external view returns (string memory) {
        if (msg.sender != s_owner) revert SecretKeeper__NotOwner();
        return s_secret;
    }
}
```

**Jangan mengubah kontrak ini.** Kamu adalah auditor eksternal.

`check.sh` mengecek **tepat 2 temuan**. Temukan keduanya dengan membandingkan setiap klaim di NatSpec dengan apa yang benar-benar dilakukan kode.

---

## 🅰️ Part A — Recon & Scoping

Auditor tidak langsung menulis exploit. Pertama, pahami dulu apa yang **seharusnya** terjadi.

### Tugas A1 — Peta kontrak

Isi tabel di `ANSWERS.md`:

| Fungsi | Siapa yang **boleh** memanggil (menurut NatSpec) | Siapa yang **bisa** memanggil (menurut kode) | Mengubah state? |
|---|---|---|---|
| `constructor` | ? | ? | ? |
| `setSecret` | ? | ? | ? |
| `getSecret` | ? | ? | ? |

### Tugas A2 — Storage layout

Jalankan:

```bash
forge inspect SecretKeeper storageLayout
```

Catat di `ANSWERS.md`: setiap variabel state berada di **slot** berapa?

### Tugas A3 — Daftar klaim

Tulis semua klaim keamanan dari NatSpec dan dari kutipan developer di atas. Untuk setiap klaim, tandai: **"terbukti benar"**, **"terbukti salah"**, atau **"belum tahu"**. Kamu akan memperbarui tabel ini setelah Part B dan C.

> Part A tidak dicek oleh `check.sh`, tetapi jangan dilewati. Hampir semua bug ditemukan pada tahap ini.

---

## 🅱️ Part B — Property Test untuk Access Control

Daripada mengetes satu penyerang, kita ingin membuktikan **properti**: *"tidak ada satu alamat pun selain owner yang bisa mengganti secret."*

### Tugas B1

Di `test/SecretKeeper.t.sol`, buat:

```solidity
function testFuzz_NonOwnerCannotSetSecret(address caller) public {
    // Implementasikan sendiri
}
```

Persyaratan:

1. `caller` adalah alamat acak dari fuzzer, **kecuali owner**.
2. Panggil `setSecret` sebagai `caller`.
3. Test ini menyatakan perilaku yang **benar** menurut NatSpec: panggilan dari non-owner harus **revert** dengan error `SecretKeeper__NotOwner`.

### Tugas B2 — Jalankan & analisis

```bash
forge test --match-test testFuzz_NonOwnerCannotSetSecret -vvv
```

Jawab di `ANSWERS.md`:

1. Apakah test-mu lulus atau gagal? Apakah itu **yang kamu harapkan**? Jelaskan.
2. Apa *counterexample* yang ditemukan fuzzer?
3. Mengapa owner harus dikecualikan dari input fuzz? Apa yang terjadi kalau tidak dikecualikan?

> Di sini test yang **gagal** adalah hasil yang baik: test itu menyatakan perilaku yang benar, dan kegagalannya membuktikan kontrak melanggar janjinya.

<details>
<summary>💡 Hint B-1 (arah)</summary>

Ada dua langkah: menyaring input yang tidak relevan (owner), lalu menyatakan bahwa panggilan berikutnya **harus revert**.

</details>

<details>
<summary>💡 Hint B-2 (konsep)</summary>

Baca [`vm.assume`](https://getfoundry.sh/reference/cheatcodes/assume) untuk menyaring input, dan [`vm.expectRevert`](https://getfoundry.sh/reference/cheatcodes/expect-revert) untuk mengharapkan revert. Custom error bisa dirujuk lewat selector-nya: `NamaKontrak.NamaError.selector`.

</details>

<details>
<summary>💡 Hint B-3 (hampir jawaban)</summary>

Urutannya: `vm.assume(caller != owner)`, `vm.prank(caller)`, `vm.expectRevert(SecretKeeper.SecretKeeper__NotOwner.selector)`, lalu panggil `setSecret` dengan string apa saja. Perhatikan bahwa `vm.expectRevert` harus dipanggil **tepat sebelum** panggilan yang diharapkan revert.

</details>

**✔️ Cek mandiri:** `./check.sh B`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅲 Part C — Proof of Code

Property test membuktikan **ada yang salah**. Sekarang buat PoC yang menunjukkan **dampaknya** dengan jelas, untuk setiap temuan.

### Tugas C1 — PoC temuan pertama

Buat test berawalan `test_PoC_` yang menunjukkan skenario serangan dari awal sampai akhir: siapa penyerangnya, apa yang ia lakukan, dan apa akibatnya bagi owner. Akhiri dengan assertion yang membuktikan akibat tersebut.

### Tugas C2 — PoC temuan kedua

Developer bilang secret aman karena `private`. Buktikan dengan test berawalan `test_PoC_` bahwa **siapa pun** bisa mengetahui secret **tanpa** memanggil `getSecret()`.

Jawab di `ANSWERS.md`:

1. Apa sebenarnya arti `private` di Solidity?
2. Dalam dunia nyata (bukan Foundry), bagaimana penyerang membaca storage kontrak yang sudah di-deploy? (Petunjuk: `cast storage`.)
3. Kenapa temuan kedua ini **tidak bisa** diperbaiki dengan sekadar menambah modifier atau `require`?

<details>
<summary>💡 Hint C-1 (arah)</summary>

Untuk temuan pertama, lihat lagi hasil Part B. Untuk temuan kedua, ingat bahwa semua data di blockchain bisa dibaca siapa pun. `private` hanya mencegah **kontrak lain** membaca variabel lewat kode Solidity.

</details>

<details>
<summary>💡 Hint C-2 (konsep)</summary>

[`vm.load(address, slot)`](https://getfoundry.sh/reference/cheatcodes/load) mengembalikan isi satu slot storage sebagai `bytes32`. Slot berapa? Lihat hasil Part A2. Untuk cara `string` disimpan, baca [Layout of State Variables — bytes and string](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html#bytes-and-string).

</details>

<details>
<summary>💡 Hint C-3 (hampir jawaban)</summary>

String yang panjangnya **kurang dari 32 byte** disimpan langsung di slot-nya: datanya rata kiri, dan **byte terakhir** berisi `panjang * 2`. Jadi ambil `bytes32 raw = vm.load(address(keeper), bytes32(uint256(<slot>)))`, hitung `len = uint8(raw[31]) / 2`, salin `len` byte pertama ke `bytes memory`, ubah menjadi `string`, lalu bandingkan dengan secret yang di-set di `setUp()`.

Untuk mitigasi temuan ini: tidak ada perbaikan satu baris. Arsitekturnya harus diubah, misalnya **jangan menyimpan data rahasia dalam bentuk plaintext di blockchain** sama sekali (simpan di luar chain, atau simpan hanya hash/komitmennya).

</details>

**✔️ Cek mandiri:** `./check.sh C`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅳 Part D — Tulis Laporan

Tulis kedua temuan di `FINDINGS.md` dengan format yang sudah disediakan: **Title, Severity, Description, Impact, Proof of Concept, Recommended Mitigation**.

### Menentukan severity

Gunakan matriks berikut (seperti di video *Severity Rating Introduction*):

| Impact ↓ / Likelihood → | High | Medium | Low |
|---|---|---|---|
| **High** | High | High | Medium |
| **Medium** | High | Medium | Low |
| **Low** | Medium | Low | Low |

- **Impact:** seberapa parah akibatnya? (dana hilang? fungsi utama protokol rusak? sekadar tidak rapi?)
- **Likelihood:** seberapa mudah terjadi? (siapa saja bisa kapan saja? butuh kondisi khusus?)

Jawab di `ANSWERS.md`:

1. Untuk setiap temuan, tulis Impact, Likelihood, dan alasannya.
2. **Judul** finding yang baik memuat *akar masalah* + *dampak*. Bandingkan dua judul ini, mana yang lebih baik dan kenapa?
   - "Bug di withdraw"
   - "`withdraw` tidak mengurangi `totalDeposits`, sehingga `totalDeposits` selalu lebih besar dari dana yang benar-benar ada di vault"

   (Contoh diambil dari UG-1, bukan dari kontrak ini.)

<details>
<summary>💡 Hint D-1 (arah)</summary>

Pikirkan tujuan utama protokol ini. Apakah kedua temuan sama-sama merusak tujuan itu? Apakah keduanya bisa dilakukan oleh siapa saja tanpa syarat?

</details>

> Part D tidak dicek oleh `check.sh`. Laporan yang jelas adalah keterampilan utama seorang auditor.

---

## 🏁 Kriteria Keberhasilan

| Part | Kriteria | Bukti |
|---|---|---|
| A | Aktor, fungsi, storage layout, dan klaim keamanan terpetakan. | Tabel di `ANSWERS.md` |
| B | Property test gagal di kontrak asli dan lulus di versi yang benar. | `./check.sh B` semua ✅ |
| C | Kedua temuan dibuktikan dengan PoC. | `./check.sh C` semua ✅ |
| D | Dua finding lengkap dengan severity yang beralasan. | `FINDINGS.md` |

---

## 🚀 Mulai Sekarang

1. Tonton materi **Part 0** di Cyfrin Updraft.
2. Kerjakan **Part A** (recon) di `ANSWERS.md`.
3. Kerjakan **Part B**, lalu jalankan `./check.sh B`.
4. Semua ✅? Lanjut ke Part C dan D.

Selamat menjalani audit pertamamu. 🔐
