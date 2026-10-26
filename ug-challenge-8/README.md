# Challenge 08 — Mini Bridge

| | |
|---|---|
| **Level** | Advanced |
| **Basis materi** | [Cyfrin Updraft — Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **Boss Bridge** (bridge, signature, arbitrary `from`, signature replay) |
| **Tools** | Solidity, Foundry (Forge) |
| **Estimasi waktu** | Menonton materi ±2–3 jam + mengerjakan 60–120 menit |
| **Fokus** | Arsitektur bridge, `approve`/`transferFrom`, tanda tangan digital (`ecrecover`, EIP-191, EIP-712), signature replay |
| **Cek jawaban** | `./check.sh` (lihat [Cek mandiri](#️-cek-mandiri-dengan-checksh)) |

> ⚠️ **Sebelum mulai, baca [Aturan Utama](../README.md#️-aturan-utama--wajib-dibaca).**
> AI hanya boleh dipakai seperti Google, yaitu untuk mencari dokumentasi dan konsep. **Kode, penjelasan, dan laporan harus kamu tulis sendiri.**

---

## 🎯 Misi Kamu

Tim **Mini Bridge** membuat jembatan token antara L1 dan L2:

- **L1 → L2:** pengguna memanggil `depositTokensToL2`. Token dikunci di `BridgeVault`, lalu operator off-chain membaca event `Deposit` dan **mencetak token yang sama di L2** untuk `l2Recipient`.
- **L2 → L1:** pengguna membakar token di L2. Setelah memverifikasinya, `signer` (kunci milik operator) menandatangani pesan penarikan. Pengguna mengirim tanda tangan itu ke `withdrawTokensToL1` untuk menerima token dari vault.

Developer mengklaim:

> *"Hanya pemilik token yang bisa mendepositkan token miliknya. Setiap tanda tangan signer hanya berlaku untuk satu kali penarikan."*

**Tugasmu adalah membuktikan, dengan test, apakah kedua klaim itu benar.**

### Setelah menyelesaikan challenge ini, kamu akan bisa:

1. Menjelaskan arsitektur **bridge** lock-and-mint: apa yang terjadi on-chain dan apa yang dipercayakan ke operator off-chain.
2. Menjelaskan risiko `transferFrom` dengan parameter `from` yang **bebas diisi**, terutama ketika pengguna memberi approve tak terbatas.
3. Membuat dan memverifikasi **tanda tangan digital** di Foundry dengan `vm.sign` dan `ecrecover`.
4. Membuktikan **signature replay** dan menjelaskan komponen yang wajib ada di pesan yang ditandatangani (nonce, chain id, alamat kontrak).
5. Menulis PoC yang memeriksa **event**, karena di bridge, event adalah "perintah" untuk L2.

---

## 📺 Part 0 — Wajib Tonton Cyfrin Updraft Dulu

Challenge ini dibangun di atas section **Boss Bridge** dari course [Smart Contract Security](https://updraft.cyfrin.io/courses/security). Tonton dulu materinya **sebelum** membuka soal.

### ✅ Wajib

- [ ] [Introduction](https://updraft.cyfrin.io/courses/security/bridges/part-intro)
- [ ] [Boss Bridge Diagram](https://updraft.cyfrin.io/courses/security/bridges/boss-bridge-diagram)
- [ ] [L1Vault.sol](https://updraft.cyfrin.io/courses/security/bridges/vault-sol)
- [ ] [L1BossBridge.sol](https://updraft.cyfrin.io/courses/security/bridges/bossbridge)
- [ ] ⭐ [Signatures](https://updraft.cyfrin.io/courses/security/bridges/signatures)
- [ ] [Signatures Summarized](https://updraft.cyfrin.io/courses/security/bridges/signatures-summarized)
- [ ] [EIP-712](https://updraft.cyfrin.io/courses/security/bridges/eip-712)
- [ ] [Signatures Recap](https://updraft.cyfrin.io/courses/security/bridges/signature-recap)
- [ ] [depositTokenToL2](https://updraft.cyfrin.io/courses/security/bridges/deposit-token)
- [ ] ⭐ [Exploit: Arbitrary From](https://updraft.cyfrin.io/courses/security/bridges/arbitrary)
- [ ] [Arbitrary From: PoC](https://updraft.cyfrin.io/courses/security/bridges/arbitrary-poc)
- [ ] [Exploit: Infinite Mint](https://updraft.cyfrin.io/courses/security/bridges/vault)
- [ ] [Why Are These Not The Same Finding?](https://updraft.cyfrin.io/courses/security/bridges/why-not-the-same)
- [ ] ⭐ [Exploit: Signature Replay](https://updraft.cyfrin.io/courses/security/bridges/exploit-replay)
- [ ] [Signature Replay: Minimized](https://updraft.cyfrin.io/courses/security/bridges/replay-minimizd)
- [ ] [Signature Replay PoC](https://updraft.cyfrin.io/courses/security/bridges/signature-replay-protection)
- [ ] [Signature Replay: Prevention](https://updraft.cyfrin.io/courses/security/bridges/sig-replay-prevention)
- [ ] [Case Study: Polygon](https://updraft.cyfrin.io/courses/security/bridges/polygon)

Codebase yang diaudit di video: [Cyfrin/7-boss-bridge-audit](https://github.com/Cyfrin/7-boss-bridge-audit). Kontrak di challenge ini **berbeda**, jadi jangan menyalin laporan dari sana.

### 🎮 Latihan pendamping (opsional)

Kerjakan **setelah** challenge ini selesai di [Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/):

- [Truster](https://www.damnvulnerabledefi.xyz/challenges/truster/): `approve` yang bisa disalahgunakan.
- [Naive Receiver](https://www.damnvulnerabledefi.xyz/challenges/naive-receiver/): memanggil fungsi atas nama orang lain.

### 📖 Dokumentasi pendamping

| Topik | Sumber |
|---|---|
| `ecrecover` | [Solidity Docs — Mathematical and Cryptographic Functions](https://docs.soliditylang.org/en/latest/units-and-global-variables.html) |
| Format pesan bertanda tangan | [EIP-191](https://eips.ethereum.org/EIPS/eip-191), [EIP-712](https://eips.ethereum.org/EIPS/eip-712) |
| Contoh verifikasi tanda tangan | [Solidity by Example — Verifying Signature](https://solidity-by-example.org/signature/) |
| Contoh signature replay | [Solidity by Example — Signature Replay](https://solidity-by-example.org/hacks/signature-replay/) |
| Membuat tanda tangan di test | [Foundry Book — `vm.sign`](https://getfoundry.sh/reference/cheatcodes/sign), [`makeAddrAndKey`](https://getfoundry.sh/reference/forge-std/make-addr-and-key) |
| Memeriksa event di test | [Foundry Book — `vm.expectEmit`](https://getfoundry.sh/reference/cheatcodes/expect-emit) |
| Library tanda tangan yang aman | [OpenZeppelin — Cryptography (ECDSA, EIP712)](https://docs.openzeppelin.com/contracts/5.x/api/utils/cryptography) |

### ✅ Self-check sebelum mulai

- [ ] Apa beda `transfer` dan `transferFrom`? Siapa yang harus `approve` siapa?
- [ ] Kenapa banyak dApp meminta approve "tak terbatas" (`type(uint256).max`)? Apa risikonya?
- [ ] Apa yang dikembalikan `ecrecover(digest, v, r, s)`? Apa artinya kalau hasilnya sama dengan alamat `signer`?
- [ ] Apa itu **signature replay**? Sebutkan tiga data yang biasanya dimasukkan ke pesan untuk mencegahnya.
- [ ] Di bridge lock-and-mint, kenapa event `Deposit` sama pentingnya dengan perpindahan token?

---

## 🧰 Setup

```bash
cd ug-challenge-8
forge build
```

Struktur folder:

```text
ug-challenge-8/
├── src/
│   ├── L1Bridge.sol          ← diaudit
│   ├── BridgeVault.sol       ← diaudit
│   └── mocks/MockToken.sol   ← di luar scope
├── test/
│   └── L1Bridge.t.sol        ← kerangka test: tulis test-mu di sini
├── ANSWERS.md                ← jawaban & penjelasan per part
├── FINDINGS.md               ← laporan temuan (Part D)
├── check.sh                  ← cek mandiri
└── foundry.toml
```

Kerangka `setUp()` sudah menyiapkan:

| Aktor / kontrak | Kondisi awal |
|---|---|
| `bridge`, `vault` | Bridge sudah di-deploy dengan `signer` milik operator. Vault sudah memberi bridge approve tak terbatas. |
| `signer`, `signerKey` | Alamat dan **kunci privat** signer. Pakai `vm.sign(signerKey, digest)` untuk mensimulasikan operator yang menandatangani penarikan. |
| `alice`, `bob` | Masing-masing punya 100 token dan sudah approve bridge **tak terbatas**. |
| `attacker` | Punya 1 token, **belum** approve apa pun. |

```bash
forge test -vvv
```

### ✔️ Cek mandiri dengan `check.sh`

```bash
./check.sh B      # cek Part B saja
./check.sh        # cek semua part
```

**Cara kerjanya:** setiap PoC milikmu dijalankan terhadap kontrak asli dan terhadap versi kontrak yang **masing-masing memperbaiki tepat satu bug**. PoC yang benar harus **lulus** di kontrak asli (bug terbukti ada) dan **gagal** di versi yang bug-nya sudah diperbaiki.

Contoh output:

```text
── Part C: test_PoC_* (temuan #2)
   ✅ Semua PoC lulus di kontrak asli (bug terbukti ada)
   ❌ Temuan #2 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)
```

**Nama test wajib:**

| Part | Nama fungsi |
|---|---|
| B, C | diawali `test_PoC_`, contoh `test_PoC_NamaBugnya()`. Satu PoC per temuan (boleh lebih). |

> ⚠️ `check.sh` hanya mengecek **kode**. Penjelasan di `ANSWERS.md` dan `FINDINGS.md` adalah bukti bahwa kamu paham, dan menjadi bahan tanya jawab saat praktikum. Semua ✅ tetapi tidak bisa menjelaskan = belum lulus.
>
> Versi-versi kontrak pembanding disimpan dalam base64 di `.check-data` supaya tidak membocorkan jawaban. Men-decode-nya sebelum selesai sama saja dengan menyontek diri sendiri.
>
> Pengguna Windows: jalankan dari terminal **Ubuntu (WSL)**, lihat [panduan instalasi](../README.md#️-instalasi-cukup-sekali).

---

## 🔍 Kontrak yang Diaudit

| File | nSLOC | Scope |
|---|---|---|
| [`src/L1Bridge.sol`](./src/L1Bridge.sol) | ±35 | ✅ In scope |
| [`src/BridgeVault.sol`](./src/BridgeVault.sol) | ±10 | ✅ In scope |
| [`src/mocks/MockToken.sol`](./src/mocks/MockToken.sol) | ±40 | ❌ Di luar scope |

**Aktor:**

| Aktor | Peran |
|---|---|
| Pengguna | Mendepositkan token ke L2, dan menarik token ke L1 dengan tanda tangan signer. |
| Signer (operator) | Kunci off-chain yang **dipercaya**. Hanya menandatangani penarikan yang sah (token sudah dibakar di L2). |
| Operator L2 | Membaca event `Deposit` di L1 dan mencetak token di L2 untuk `l2Recipient`. |

**Alur:**

```text
 L1 → L2:  depositTokensToL2(from, l2Recipient, amount)
           token: from ──transferFrom──► BridgeVault
           emit Deposit(from, l2Recipient, amount)  ──► operator mencetak `amount` di L2 untuk l2Recipient

 L2 → L1:  (bakar token di L2) ──► signer menandatangani digest(to, amount)
           withdrawTokensToL1(to, amount, v, r, s)
           token: BridgeVault ──transferFrom──► to
```

Baca kedua kontrak dengan teliti, terutama **NatSpec**-nya.

**`check.sh` mengecek tepat 2 temuan.**

### 🚫 Di luar scope (known issues)

- `signer` dan operator L2 dianggap jujur (risiko sentralisasi dibahas di Part D).
- `MockToken` dan fungsi `mint`-nya.

---

## 🅰️ Part A — Recon (tanpa kode)

Jawab di `ANSWERS.md`:

1. **Kepercayaan.** Apa saja yang **dipercayakan** protokol ini ke pihak off-chain (operator L2 dan signer)? Apa yang terjadi kalau event `Deposit` berisi data yang salah?
2. **Approval.** Siapa saja yang memberi `approve` ke bridge, dan berapa besarnya? (Lihat `setUp()` dan constructor `BridgeVault`.)
3. **Pesan yang ditandatangani.** Data apa saja yang masuk ke `getWithdrawalDigest`? Data apa yang **tidak** ada di sana?
4. **Daftar klaim.** Tulis setiap klaim keamanan dari NatSpec, lalu tandai "benar", "salah", atau "belum tahu". Perbarui setelah Part B dan C.

<details>
<summary>💡 Hint A-1 (arah)</summary>

Untuk setiap parameter fungsi external, tanyakan: *"siapa yang mengisi parameter ini, dan apakah kontrak memeriksa bahwa nilainya masuk akal untuk pemanggil itu?"*

</details>

> Part A tidak dicek oleh `check.sh`, tetapi jangan dilewati.

---

## 🅱️ Part B — Klaim "Hanya pemilik token yang bisa mendepositkan"

### Tugas B1 — Analisis

Jawab di `ANSWERS.md`:

1. Di `depositTokensToL2`, siapa yang **menentukan** nilai `from`? Apakah ada pemeriksaan bahwa `from` adalah pemanggil?
2. Alice sudah approve bridge tak terbatas. Apa yang bisa dilakukan penyerang terhadap token Alice? Siapa yang menerima token di L2?
3. Vault juga memberi bridge approve tak terbatas. Apa yang terjadi kalau `from` diisi alamat **vault**? Kenapa itu berbahaya bagi L2, walaupun token di L1 tidak berpindah ke mana-mana?

### Tugas B2 — PoC

Tulis test `test_PoC_...` yang membuktikan penyerang bisa membuat token **milik orang lain** dikunci dan dicetak di L2 untuk **penyerang**. Buktikan dua hal:

1. Saldo korban di L1 berkurang.
2. Event `Deposit` yang dibaca operator L2 menyebut **penyerang** sebagai `l2Recipient`.

<details>
<summary>💡 Hint B-1 (arah)</summary>

Penyerang tidak butuh approval dari korban, karena korban sudah memberi approval ke **bridge**. Penyerang cukup menyuruh bridge memakai approval itu.

</details>

<details>
<summary>💡 Hint B-2 (konsep)</summary>

Tonton ulang [Exploit: Arbitrary From](https://updraft.cyfrin.io/courses/security/bridges/arbitrary). Untuk memeriksa event, baca [`vm.expectEmit`](https://getfoundry.sh/reference/cheatcodes/expect-emit): kamu menuliskan event yang **diharapkan** tepat sebelum panggilan yang memancarkannya. Event bisa dirujuk lewat nama kontraknya, misalnya `emit L1Bridge.Deposit(...)`.

</details>

<details>
<summary>💡 Hint B-3 (hampir jawaban)</summary>

`vm.expectEmit(true, true, false, true, address(bridge))`, lalu `emit L1Bridge.Deposit(alice, attacker, 100e18)`. Setelah itu `vm.prank(attacker)` dan panggil `bridge.depositTokensToL2(alice, attacker, 100e18)`. Assert saldo Alice `0` dan saldo vault `100e18`. Untuk varian vault: isi `from` dengan `address(vault)` dan tunjukkan event `Deposit` tetap terpancar.

</details>

**✔️ Cek mandiri:** `./check.sh B`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅲 Part C — Klaim "Satu tanda tangan, satu penarikan"

### Tugas C1 — Analisis

Jawab di `ANSWERS.md`:

1. Setelah `withdrawTokensToL1` berhasil, apakah ada state yang berubah di `L1Bridge` yang menandai tanda tangan itu sudah dipakai?
2. Kalau penyerang punya **satu** tanda tangan sah untuk menarik 1 token, berapa token maksimal yang bisa ia tarik?
3. Selain dipakai ulang di bridge yang sama, di mana lagi tanda tangan ini bisa dipakai ulang? (Petunjuk: lihat jawaban A3.)

### Tugas C2 — PoC

Tulis test `test_PoC_...` dengan skenario realistis:

1. Alice dan Bob mendepositkan token mereka ke L2 (vault terisi).
2. Penyerang mendepositkan 1 token miliknya secara **sah**, lalu menarik 1 token kembali dengan tanda tangan signer yang **sah** (`vm.sign(signerKey, ...)`).
3. Tunjukkan penyerang bisa menguras vault dengan tanda tangan yang sama.

> **Aturan PoC:** replay harus dilakukan di **bridge yang sama**. Membuktikan tanda tangan bisa dipakai di bridge lain (cross-contract) atau chain lain (cross-chain) adalah analisis yang bagus untuk C1.3 dan laporanmu, tetapi bukan bug yang dicek di Part C.

<details>
<summary>💡 Hint C-1 (arah)</summary>

Tanda tangan hanyalah data. Kalau kontrak tidak "mengingat" bahwa data itu sudah dipakai, tidak ada yang mencegahnya dikirim lagi.

</details>

<details>
<summary>💡 Hint C-2 (konsep)</summary>

Tonton ulang [Signature Replay: Minimized](https://updraft.cyfrin.io/courses/security/bridges/replay-minimizd). Untuk membuat tanda tangan di test: `(uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, bridge.getWithdrawalDigest(to, amount));`. Jangan lupa penyerang harus `approve` bridge dulu sebelum deposit.

</details>

<details>
<summary>💡 Hint C-3 (hampir jawaban)</summary>

Setelah deposit sah 1 token, buat tanda tangan untuk `(attacker, 1e18)`, lalu panggil `withdrawTokensToL1` di dalam loop `while (token.balanceOf(address(vault)) >= 1e18)`. Assert saldo vault `0` dan saldo penyerang `201e18` (100 dari Alice + 100 dari Bob + 1 miliknya sendiri).

</details>

**✔️ Cek mandiri:** `./check.sh C`. Lanjut ke part berikutnya kalau semua sudah ✅.

---

## 🅳 Part D — Laporan & Mitigasi

Tulis **2 finding** di `FINDINGS.md` memakai template yang tersedia: Title, Severity (Impact × Likelihood), Description, Impact, Proof of Concept, Recommended Mitigation.

Jawab juga di `ANSWERS.md`:

1. **Satu temuan atau dua?** Mencuri token Alice dan "mencetak gratis" lewat `from = vault` punya akar masalah yang sama. Haruskah dilaporkan sebagai satu finding atau dua? Kaitkan dengan lesson *Why Are These Not The Same Finding?*.
2. **Mitigasi replay.** Menyimpan "digest yang sudah dipakai" memang menghentikan replay di bridge yang sama. Kenapa cara itu masih kurang? Rancang ulang isi pesan yang ditandatangani dengan **nonce**, **chain id**, dan **alamat kontrak** (lihat [EIP-712](https://eips.ethereum.org/EIPS/eip-712)).
3. **Sentralisasi.** Apa yang terjadi kalau kunci `signer` bocor? Mitigasi apa yang dipakai bridge sungguhan? Kaitkan dengan *Case Study: Polygon*.

<details>
<summary>💡 Hint D-1 (arah)</summary>

Untuk mitigasi temuan pertama, pertanyaannya sederhana: *siapa satu-satunya alamat yang boleh menjadi `from`?*

</details>

> Part D tidak dicek oleh `check.sh`. Laporan yang jelas adalah keterampilan utama seorang auditor, dan akan dibahas saat praktikum.

---

## 🏁 Kriteria Keberhasilan

| Part | Kriteria | Bukti |
|---|---|---|
| A | Asumsi kepercayaan, approval, dan isi pesan bertanda tangan dipetakan. | `ANSWERS.md` |
| B | Deposit atas nama orang lain dibuktikan, termasuk event yang menguntungkan penyerang. | `./check.sh B` ✅ + penjelasan |
| C | Signature replay dibuktikan sampai vault terkuras. | `./check.sh C` ✅ + penjelasan |
| D | Dua finding lengkap + rancangan pesan EIP-712 + analisis sentralisasi. | `FINDINGS.md`, `ANSWERS.md` |

---

## 🚀 Mulai Sekarang

1. Tonton materi **Part 0** di Cyfrin Updraft.
2. Kerjakan **Part A** di `ANSWERS.md`.
3. Kerjakan **Part B**, lalu jalankan `./check.sh B`.
4. Semua ✅? Lanjut ke Part C dan D.

Target akhirnya: setiap kali melihat `transferFrom` atau `ecrecover`, kamu otomatis bertanya *"siapa yang mengisi parameternya, dan apakah tanda tangan ini bisa dipakai lebih dari sekali?"*
