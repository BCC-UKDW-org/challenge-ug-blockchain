# Challenge 07 — Upgrade Trap

| | |
|---|---|
| **Level** | Advanced |
| **Basis materi** | [Cyfrin Updraft — Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **Thunder Loan** (proxy, storage collision, failure to initialize, centralization) |
| **Tools** | Solidity, Foundry (Forge), `forge inspect` |
| **Estimasi waktu** | Menonton materi ±2–3 jam + mengerjakan 90–150 menit |
| **Fokus** | Pola proxy & `delegatecall`, storage layout, upgrade yang aman, inisialisasi, risiko sentralisasi |
| **Cek jawaban** | `./check.sh` (lihat [Cek mandiri](#️-cek-mandiri-dengan-checksh)) |

> ⚠️ **Sebelum mulai, baca [Aturan Utama](../README.md#️-aturan-utama--wajib-dibaca).**
> AI hanya boleh dipakai seperti Google, yaitu untuk mencari dokumentasi dan konsep. **Kode, penjelasan, dan laporan harus kamu tulis sendiri.**

---

## 🎯 Misi Kamu

Tim **StakingVault** menjalankan vault tempat pengguna menitipkan ETH. Supaya bisa menambah fitur tanpa memindahkan dana, mereka memakai **proxy yang bisa di-upgrade**:

- `VaultProxy` menyimpan semua **state** (owner, saldo, stake).
- `StakingVaultV1` berisi **logika**. Proxy meneruskan setiap panggilan ke sana lewat `delegatecall`.
- Bulan depan, owner akan meng-upgrade ke `StakingVaultV2`, yang menambah fitur **biaya penarikan** (withdrawal fee).

Developer mengklaim:

> *"Hanya owner yang bisa meng-upgrade vault. Upgrade ke V2 aman: semua stake dari V1 tetap utuh."*

**Tugasmu adalah membuktikan, dengan test, apakah kedua klaim itu benar.**

### Setelah menyelesaikan challenge ini, kamu akan bisa:

1. Menjelaskan cara kerja **proxy** dan **`delegatecall`**: kode siapa yang dijalankan, storage siapa yang dipakai.
2. Membaca dan membandingkan **storage layout** dua versi kontrak dengan `forge inspect`.
3. Menemukan dan membuktikan **storage collision** setelah upgrade.
4. Menemukan dan membuktikan masalah **inisialisasi** pada kontrak upgradeable.
5. Menulis **test upgrade** yang menjadi pengaman untuk upgrade berikutnya.
6. Menilai **risiko sentralisasi** pada kontrak yang bisa di-upgrade.

---

## 📺 Part 0 — Wajib Tonton Cyfrin Updraft Dulu

Challenge ini dibangun di atas section **Review** dan **Thunder Loan** dari course [Smart Contract Security](https://updraft.cyfrin.io/courses/security). Tonton dulu materinya **sebelum** membuka soal.

### ✅ Wajib

- [ ] [Storage](https://updraft.cyfrin.io/courses/security/review/storage) (section Review)
- [ ] ⭐ [Upgradeable Contracts](https://updraft.cyfrin.io/courses/security/review/upgradeable-contracts) (section Review)
- [ ] [OracleUpgradeable.sol](https://updraft.cyfrin.io/courses/security/thunder-loan/oracle-upgradeable)
- [ ] ⭐ [Exploit: Failure To Initialize](https://updraft.cyfrin.io/courses/security/thunder-loan/failure-to-initialize)
- [ ] [Failure To Initialize: Remix](https://updraft.cyfrin.io/courses/security/thunder-loan/failure-to-initialize-remix)
- [ ] [Case Study: Failure To Initialize](https://updraft.cyfrin.io/courses/security/thunder-loan/failure-to-initialize-case-study)
- [ ] ⭐ [Exploit: Storage Collision](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-storage-collision-storage-refresher)
- [ ] [Storage Collision: Diagram](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-storage-collision-diagram)
- [ ] [Storage Collision: Remix Example](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-storage-collision-remix-examplee)
- [ ] [Storage Collision: PoC](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-storage-collision-poc)
- [ ] [Reporting: Storage Collision](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-storage-collision-write-up)
- [ ] [Exploit: Centralization](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-centralization)
- [ ] [Case Study: Oasis](https://updraft.cyfrin.io/courses/security/thunder-loan/case-study-oasis)

Codebase yang diaudit di video: [Cyfrin/6-thunder-loan-audit](https://github.com/Cyfrin/6-thunder-loan-audit). Kontrak di challenge ini **berbeda**, jadi jangan menyalin laporan dari sana.

### 🎮 Latihan pendamping (opsional)

- [Ethernaut](https://ethernaut.openzeppelin.com/): level **Delegation**, **Puzzle Wallet**, dan **Motorbike**.

### 📖 Dokumentasi pendamping

| Topik | Sumber |
|---|---|
| `delegatecall` | [Solidity by Example — Delegatecall](https://solidity-by-example.org/delegatecall/) |
| Contoh proxy sederhana | [Solidity by Example — Upgradeable Proxy](https://solidity-by-example.org/app/upgradeable-proxy/) |
| Slot implementation standar | [EIP-1967](https://eips.ethereum.org/EIPS/eip-1967) |
| Aturan menulis kontrak upgradeable | [OpenZeppelin — Writing Upgradeable Contracts](https://docs.openzeppelin.com/upgrades-plugins/writing-upgradeable) |
| Cara kerja proxy | [OpenZeppelin — Proxy Upgrade Pattern](https://docs.openzeppelin.com/upgrades-plugins/proxies) |
| Layout storage | [Solidity Docs — Layout of State Variables in Storage](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html) |
| Membaca storage dari test | [Foundry Book — `vm.load`](https://getfoundry.sh/reference/cheatcodes/load) |
| Melihat storage layout | jalankan `forge inspect <NamaKontrak> storageLayout` |

### ✅ Self-check sebelum mulai

- [ ] Saat proxy memanggil implementation dengan `delegatecall`, `msg.sender`, `address(this)`, dan storage milik siapa yang dipakai?
- [ ] Mengapa kontrak upgradeable memakai fungsi `initialize` dan bukan `constructor`?
- [ ] Bagaimana Solidity menentukan slot storage untuk setiap variabel state?
- [ ] Apa yang dimaksud **storage collision**?
- [ ] Apa saja yang bisa dilakukan seseorang yang menguasai fungsi upgrade?

---

## 🧰 Setup

```bash
cd ug-challenge-7
forge build
```

Struktur folder:

```text
ug-challenge-7/
├── src/
│   ├── VaultProxy.sol          ← proxy (in scope)
│   ├── StakingVaultV1.sol      ← implementation yang sedang dipakai (in scope)
│   └── StakingVaultV2.sol      ← implementation untuk upgrade berikutnya (in scope)
├── test/
│   └── StakingVault.t.sol      ← kerangka test: tulis test-mu di sini
├── ANSWERS.md                  ← jawaban & penjelasan per part
├── FINDINGS.md                 ← laporan temuan (Part D)
├── check.sh                    ← cek mandiri
└── foundry.toml
```

Kerangka test sudah mengikuti **alur deploy resmi**: deploy `StakingVaultV1`, deploy `VaultProxy`, lalu `initialize(owner)` lewat proxy. `StakingVaultV2` juga sudah di-deploy, tetapi **belum** dipakai.

> **Penting:** selalu berinteraksi lewat variabel `vault` (yaitu proxy), **bukan** lewat `implementationV1`. Setelah upgrade, "lihat" proxy sebagai V2 dengan `StakingVaultV2(address(proxy))`.

```bash
forge test -vvv
```

### ✔️ Cek mandiri dengan `check.sh`

```bash
./check.sh B      # cek Part B saja
./check.sh        # cek semua part
```

**Cara kerjanya:** test milikmu dijalankan terhadap kontrak asli dan terhadap versi kontrak yang **masing-masing memperbaiki tepat satu bug**.

- **PoC** (`test_PoC_*`) yang benar harus **lulus** di kontrak asli dan **gagal** ketika bug-nya diperbaiki.
- **Test upgrade** (`test_UpgradePreservesState`) menyatakan perilaku yang **benar**, sehingga harus **gagal** di kontrak asli dan **lulus** di versi yang sudah benar.

Contoh output:

```text
── Part C: test_UpgradePreservesState
   ✅ Test upgrade menemukan masalah di kontrak asli
   ❌ Test upgrade lulus di versi yang sudah benar (tidak ada false positive)
```

**Nama test wajib:**

| Part | Nama fungsi |
|---|---|
| B, C | PoC diawali `test_PoC_`, contoh `test_PoC_NamaBugnya()`. Satu PoC per temuan. |
| C | `test_UpgradePreservesState()` |

> ⚠️ `check.sh` hanya mengecek **kode**. Penjelasan di `ANSWERS.md` dan `FINDINGS.md` adalah bukti bahwa kamu paham, dan tim BCC UKDW bisa memintamu menjelaskannya kapan saja. Semua ✅ tetapi tidak bisa menjelaskan = belum lulus.
>
> Versi-versi kontrak pembanding disimpan dalam base64 di `.check-data` supaya tidak membocorkan jawaban. Men-decode-nya sebelum selesai sama saja dengan menyontek diri sendiri.
>
> Pengguna Windows: jalankan dari terminal **Ubuntu (WSL)**, lihat [panduan instalasi](../README.md#️-instalasi-cukup-sekali).

---

## 🔍 Kontrak yang Diaudit

| File | nSLOC | Scope |
|---|---|---|
| `src/VaultProxy.sol` | ±30 | ✅ In scope |
| `src/StakingVaultV1.sol` | ±45 | ✅ In scope |
| `src/StakingVaultV2.sol` | ±60 | ✅ In scope |

**Aktor:**

| Aktor | Peran |
|---|---|
| Owner | Men-deploy sistem, memanggil `initialize`, dan satu-satunya yang boleh `upgradeTo` serta (di V2) `setWithdrawalFee`. |
| Staker | Menitipkan ETH (`stake`) dan menariknya kembali (`unstake`). |
| Siapa saja | Bisa memanggil fungsi apa pun lewat proxy. |

**Rencana upgrade dari developer:**

```text
Sekarang:   VaultProxy ──delegatecall──► StakingVaultV1
Bulan depan: owner memanggil vault.upgradeTo(address(StakingVaultV2))
Sesudahnya: VaultProxy ──delegatecall──► StakingVaultV2   (stake V1 "tetap utuh")
```

Baca ketiga file di `src/` dengan teliti, terutama **NatSpec**-nya. Di sana developer menuliskan perilaku yang **dimaksud**.

**`check.sh` mengecek tepat 2 temuan.**

### 🚫 Di luar scope (known issues)

Hal-hal berikut **tidak** dicek oleh `check.sh`, tetapi dibahas di Part D:

- Owner bisa meng-upgrade ke implementation apa pun kapan saja (risiko sentralisasi).
- Kontrak **implementation** itu sendiri (bukan proxy) juga punya fungsi `initialize` yang bisa dipanggil siapa saja. Di desain ini, hal tersebut tidak berdampak pada dana di proxy. Kamu tetap boleh mencatatnya sebagai Low/Informational.

---

## 🅰️ Part A — Recon: Proxy & Storage Layout (tanpa kode)

Jawab di `ANSWERS.md`:

1. **Alur panggilan.** Ketika Alice memanggil `vault.stake{value: 1 ether}()`, jelaskan langkah demi langkah apa yang terjadi: fungsi apa di proxy yang terpanggil, kode siapa yang dijalankan, dan storage siapa yang berubah.
2. **Storage layout.** Jalankan:

   ```bash
   forge inspect StakingVaultV1 storageLayout
   forge inspect StakingVaultV2 storageLayout
   ```

   Salin hasilnya ke tabel di `ANSWERS.md` dan bandingkan **slot per slot**.
3. **Alamat implementation.** Mengapa proxy menyimpan alamat implementation di slot `0x3608…2bbc` dan bukan di slot `0`? Apa yang terjadi kalau disimpan di slot `0`?
4. **Daftar klaim.** Tulis setiap klaim keamanan dari NatSpec dan dari kutipan developer, lalu tandai "benar", "salah", atau "belum tahu". Perbarui setelah Part B dan C.

<details>
<summary>💡 Hint A-1 (arah)</summary>

Fokus pada dua hal: fungsi mana yang menurut NatSpec "hanya boleh dipanggil sekali", dan apakah urutan variabel state di V1 dan V2 sama persis.

</details>

> Part A tidak dicek oleh `check.sh`, tetapi jangan dilewati. Hampir semua bug di challenge ini ditemukan dengan membaca, bukan dengan menjalankan test.

---

## 🅱️ Part B — Klaim "Hanya owner yang bisa meng-upgrade"

### Tugas B1 — Analisis

Jawab di `ANSWERS.md`:

1. NatSpec `initialize` berkata "hanya boleh dipanggil SATU KALI". Baris kode mana yang menegakkan aturan itu?
2. Kalau aturan itu tidak ditegakkan, apa yang bisa dilakukan penyerang yang **bukan** owner?
3. Apa dampak terburuknya bagi dana para staker?

### Tugas B2 — PoC

Tulis test `test_PoC_...` yang membuktikan dampak terburuknya. Alice dan Bob sudah stake; tunjukkan bahwa penyerang bisa mengambil alih vault dan membawa kabur **seluruh** ETH di dalamnya. Akhiri dengan assertion saldo proxy dan saldo penyerang.

<details>
<summary>💡 Hint B-1 (arah)</summary>

Pertama kuasai jabatan owner, lalu manfaatkan hak istimewa owner. Hak istimewa apa yang paling berbahaya di kontrak upgradeable?

</details>

<details>
<summary>💡 Hint B-2 (konsep)</summary>

Tonton ulang [Exploit: Failure To Initialize](https://updraft.cyfrin.io/courses/security/thunder-loan/failure-to-initialize). Ingat bahwa setelah upgrade, **kode** implementation baru dijalankan dengan **storage dan saldo ETH milik proxy**. Implementation baru itu bisa ditulis oleh siapa pun yang berhak meng-upgrade.

Hati-hati: memanggil `initialize` di `implementationV1` (bukan lewat proxy) **tidak** membuktikan apa pun tentang dana staker. Storage siapa yang berubah dalam kasus itu?

</details>

<details>
<summary>💡 Hint B-3 (hampir jawaban)</summary>

Buat kontrak `EvilImplementation` di file test dengan satu fungsi yang mengirim `address(this).balance` ke alamat penyerang. Sebagai penyerang: panggil `vault.initialize(attacker)`, deploy `EvilImplementation`, panggil `vault.upgradeTo(address(evil))`, lalu panggil fungsi pengurasnya lewat `EvilImplementation(address(proxy))`. Assert saldo proxy menjadi `0`.

</details>

**✔️ Cek mandiri:** `./check.sh B`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅲 Part C — Klaim "Upgrade ke V2 aman"

### Tugas C1 — Test upgrade (perilaku yang benar)

Sebelum mencari bug, tulis test yang menyatakan apa artinya upgrade yang **benar**. Test seperti ini seharusnya ditulis developer **sebelum** setiap upgrade.

Buat `test_UpgradePreservesState()`:

1. Alice dan Bob stake dengan jumlah berbeda.
2. Owner meng-upgrade proxy ke `StakingVaultV2`.
3. Assert semua state penting **sama** seperti sebelum upgrade: `owner`, `totalStaked`, stake setiap pengguna, dan fee awal `0`.
4. Assert pengguna masih bisa `unstake` dan menerima ETH-nya kembali.

Jalankan test ini. Apakah lulus? Apakah itu sesuai harapanmu?

### Tugas C2 — Investigasi

Jawab di `ANSWERS.md`:

1. Setelah upgrade, berapa nilai `owner()`, `withdrawalFeeBps()`, `totalStaked()`, dan `stakes(alice)` yang **terbaca** lewat V2? Jelaskan dari mana setiap angka itu berasal, dengan merujuk tabel storage layout dari Part A.
2. Mengapa `stakes(alice)` terbaca berbeda padahal datanya tidak pernah dihapus? (Petunjuk: bagaimana slot sebuah `mapping` dihitung?)
3. Bisakah keadaan ini diperbaiki setelah upgrade terjadi? Siapa yang bisa memperbaikinya?

### Tugas C3 — PoC

Tulis test `test_PoC_...` yang menunjukkan **dampak** upgrade ini bagi pengguna. Pilih assertion yang paling meyakinkan untuk developer.

<details>
<summary>💡 Hint C-1 (arah)</summary>

Bandingkan output `forge inspect` V1 dan V2 dari Part A. Variabel baru di V2 ditaruh di mana?

</details>

<details>
<summary>💡 Hint C-2 (konsep)</summary>

Tonton ulang [Storage Collision: Diagram](https://updraft.cyfrin.io/courses/security/thunder-loan/exploit-storage-collision-diagram). Untuk mapping, data `stakes[user]` disimpan di `keccak256(abi.encode(user, slotMapping))`. Kalau `slotMapping` berubah, alamat datanya ikut berubah. Kamu bisa membuktikannya dengan `vm.load`.

</details>

<details>
<summary>💡 Hint C-3 (hampir jawaban)</summary>

Setelah upgrade: `stakes(alice)` terbaca `0`, `owner()` bukan lagi owner asli (terbaca dari slot yang dulu berisi `totalStaked`), dan `unstake` oleh Alice revert dengan `"StakingVault: insufficient stake"`, padahal ETH-nya masih ada di proxy. Assert keempat hal ini. Perbaikannya: variabel baru **selalu ditambahkan di akhir**, setelah semua variabel lama.

</details>

**✔️ Cek mandiri:** `./check.sh C`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅳 Part D — Laporan & Sentralisasi

Tulis **2 finding** di `FINDINGS.md` memakai template yang tersedia: Title, Severity (Impact × Likelihood), Description, Impact, Proof of Concept, Recommended Mitigation.

Jawab juga di `ANSWERS.md`:

1. **Mitigasi temuan inisialisasi.** Sebutkan dua cara memperbaikinya. Mengapa sebaiknya `initialize` dipanggil **di transaksi yang sama** dengan deploy proxy?
2. **Mitigasi storage collision.** Selain "tambahkan variabel di akhir", sebutkan teknik lain yang dipakai proyek nyata untuk mencegah collision antar versi (misalnya *storage gap* atau *namespaced storage*).
3. **Sentralisasi.** Walaupun kedua bug diperbaiki, owner tetap bisa meng-upgrade ke kode apa pun. Apakah ini sebuah temuan? Berapa severity-nya menurutmu, dan apa mitigasinya (misalnya multisig, timelock)? Kaitkan dengan *Case Study: Oasis*.

<details>
<summary>💡 Hint D-1 (arah)</summary>

Untuk sentralisasi, auditor biasanya tidak menganggapnya bug kode, tetapi **risiko kepercayaan**. Pikirkan: apa yang terjadi kalau private key owner dicuri?

</details>

> Part D tidak dicek oleh `check.sh`. Laporan yang jelas adalah keterampilan utama seorang auditor.

---

## 🏁 Kriteria Keberhasilan

| Part | Kriteria | Bukti |
|---|---|---|
| A | Alur `delegatecall` dijelaskan dan storage layout V1 vs V2 dibandingkan slot per slot. | `ANSWERS.md` |
| B | Pengambilalihan vault dan pengurasan dana dibuktikan lewat proxy. | `./check.sh B` ✅ + penjelasan |
| C | Test upgrade yang benar ditulis, dan dampak upgrade ke V2 dibuktikan. | `./check.sh C` ✅ + penjelasan angka |
| D | Dua finding lengkap + analisis risiko sentralisasi. | `FINDINGS.md`, `ANSWERS.md` |

---

## 🚀 Mulai Sekarang

1. Tonton materi **Part 0** di Cyfrin Updraft.
2. Kerjakan **Part A** di `ANSWERS.md` (jangan lewatkan `forge inspect`).
3. Kerjakan **Part B**, lalu jalankan `./check.sh B`.
4. Semua ✅? Lanjut ke Part C dan D.

Target akhirnya: setiap kali melihat kontrak upgradeable, kamu otomatis bertanya *"siapa yang bisa meng-upgrade, apakah inisialisasinya terkunci, dan apakah layout storage-nya aman?"*
