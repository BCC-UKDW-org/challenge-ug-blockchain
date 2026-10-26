<p align="center">
  <img src="./bcc-ukdw/logo.jpeg" alt="BCC UKDW — Duta Wacana Web3" width="180" />
</p>

# UG Blockchain Challenges

Kumpulan challenge **audit smart contract** untuk praktikum **UG (Unguided)** di Universitas Kristen Duta Wacana, dan terbuka juga untuk publik.

Repositori ini bukan sekadar kumpulan soal. Tujuannya melatih kamu **berpikir seperti security researcher**: membaca kode secara curiga, merumuskan aturan yang seharusnya selalu benar, lalu membuktikan pelanggarannya dengan test.

> **Unguided** artinya kamu tidak akan disuapi jawaban. Kamu akan diberi arah, dokumentasi, dan petunjuk bertingkat. Sisanya harus kamu kerjakan sendiri.

---

## Daftar Challenge

| No | Challenge | Topik | Level | Status |
|---|---|---|---|---|
| 01 | [Vault Invariant Hunter](./ug-challenge-1/) | Stateless & stateful fuzzing, invariant, handler, reentrancy | Beginner → Intermediate | ✅ Tersedia |

Challenge berikutnya akan menyusul.

---

## ⚠️ Aturan Utama — Wajib Dibaca

### 1. AI hanya boleh dipakai seperti Google, bukan sebagai programmer kamu

Kita belajar **menulis** smart contract dan test, bukan belajar **mem-prompt** smart contract. Auditor yang tidak bisa membaca dan menulis kode sendiri tidak akan bisa menemukan bug yang tidak diketahui AI.

| ✅ Boleh (AI sebagai mesin pencari / dokumentasi) | ❌ Dilarang (AI sebagai pengerja) |
|---|---|
| "Apa fungsi `vm.prank` di Foundry?" | "Buatkan fuzz test untuk fungsi deposit ini." |
| "Apa beda `bound()` dan `vm.assume()`?" | "Tulis handler invariant untuk SimpleVault." |
| "Apa itu pola Checks-Effects-Interactions?" | "Apa bug di kontrak ini?" (sambil menempel kode challenge) |
| "Arti error `Linearization of inheritance graph impossible`?" | "Perbaiki test saya sampai hijau." |
| "Tunjukkan link dokumentasi invariant testing di Foundry Book." | "Tuliskan laporan finding untuk bug ini." |
| "Jelaskan arti output `-vvvv` ini baris per baris." | Menyalin jawaban AI ke `ANSWERS.md` atau `FINDINGS.md`. |

**Aturan praktis:** kalau pertanyaanmu tetap masuk akal tanpa menempelkan kode challenge, kemungkinan besar pertanyaan itu boleh. Kalau kamu menempelkan kode challenge lalu meminta solusi, itu dilarang.

### 2. Setiap baris harus bisa kamu jelaskan

- Setiap assertion, `bound()`, `vm.prank()`, dan keputusan desain di test kamu harus disertai alasan di `ANSWERS.md`, **ditulis dengan kata-katamu sendiri**.
- Kode yang tidak bisa kamu jelaskan **dianggap tidak valid**, walaupun test-nya hijau.

### 3. Siap untuk defense (tanya jawab)

Mentor dapat sewaktu-waktu memintamu menjelaskan kode secara langsung, baik saat praktikum, lewat voice note, maupun di komentar PR. Contoh pertanyaan:

- "Kenapa kamu pakai `bound` dan bukan `vm.assume` di sini?"
- "Apa yang terjadi kalau baris ini dihapus?"
- "Tunjukkan di trace bagian mana invariant-nya dilanggar."

Kalau kamu menulis sendiri kodenya, pertanyaan seperti ini mudah dijawab. Kalau kamu menyalin, akan terlihat.

### 4. Kejujuran akademik

- **Dilarang menyalin** submission peserta lain (termasuk dari PR yang terbuka). Membaca untuk belajar setelah PR-mu sendiri di-approve diperbolehkan.
- Cantumkan sumber (artikel, video, dokumentasi) yang kamu pakai di bagian **Referensi** pada `ANSWERS.md`.
- Catat dengan jujur hint mana saja yang kamu buka. Membuka hint **tidak mengurangi nilai**, tetapi tidak jujur soal hint justru mengurangi.

---

## 🛠️ Persiapan

### 1. Install tools

| Tool | Cek versi | Cara install |
|---|---|---|
| Git | `git --version` | <https://git-scm.com/downloads> |
| Foundry | `forge --version` | <https://getfoundry.sh/introduction/installation> |
| VS Code + extension Solidity (opsional) | — | <https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity> |

Install Foundry:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Fork dan clone

1. Klik tombol **Fork** di kanan atas halaman GitHub repo ini.
2. Clone fork milikmu. **Jangan lupa `--recurse-submodules`**, karena `forge-std` dipasang sebagai submodule:

```bash
git clone --recurse-submodules https://github.com/<username-kamu>/challenge-ug-blockchain.git
cd challenge-ug-blockchain
```

Kalau sudah terlanjur clone tanpa flag tersebut:

```bash
git submodule update --init --recursive
```

3. Pastikan semuanya berjalan:

```bash
cd ug-challenge-1
forge build
```

Kalau muncul `Compiler run successful!`, kamu siap mulai.

---

## 🔁 Alur Pengerjaan & Submit

Setiap challenge dikerjakan **bertahap per part** (A → B → C → D). Setiap part = **satu Pull Request**. Kamu baru boleh lanjut ke part berikutnya setelah PR sebelumnya **di-approve** mentor.

```text
 Belajar materi  ─►  Kerjakan Part A  ─►  PR [A]  ─►  Review mentor  ─►  Approved?
                                                          ▲               │
                                                          └── revisi ◄── tidak
                                                                          │ ya
                                                                          ▼
                                                                  Lanjut Part B ...
```

### Langkah per part

**1. Siapkan folder kerjamu** (hanya sekali per challenge):

```bash
cd ug-challenge-1
cp -r submissions/_template submissions/<username-github>
```

Semua pekerjaanmu ditulis **hanya** di dalam `submissions/<username-github>/`. Jangan mengubah file di `src/` atau di folder milik orang lain.

**2. Buat branch untuk part yang dikerjakan:**

```bash
git checkout main
git pull upstream main          # sinkronkan dengan repo utama (lihat catatan di bawah)
git checkout -b ug1-<username>-part-a
```

**3. Kerjakan, lalu jalankan test hanya untuk folder kamu:**

```bash
forge test --match-path "submissions/<username-github>/*" -vvv
```

**4. Commit dan push:**

```bash
git add submissions/<username-github>
git commit -m "ug-challenge-1: part A - <username>"
git push origin ug1-<username>-part-a
```

**5. Buka Pull Request** ke repo utama dengan judul:

```text
[UG-1][Part A] <username-github>
```

Isi deskripsi PR mengikuti template yang otomatis muncul (output `forge test`, penjelasan, dan hint yang dibuka).

**6. Tunggu review.** Balas komentar mentor, perbaiki dengan menambah commit di branch yang sama, lalu tunggu label **approved**. Setelah PR di-merge, ulangi dari langkah 2 untuk part berikutnya.

> **Catatan `upstream`:** tambahkan repo utama sebagai remote satu kali saja:
> `git remote add upstream https://github.com/<pemilik-repo>/challenge-ug-blockchain.git`

### Apa yang dinilai?

Yang dinilai bukan hanya test yang hijau, tetapi juga:

1. **Pemahaman:** penjelasan di `ANSWERS.md` menunjukkan kamu tahu *mengapa*, bukan hanya *apa*.
2. **Ketepatan:** assertion dan invariant benar-benar menguji hal yang penting.
3. **Kemampuan investigasi:** kamu bisa membaca trace dan call sequence ketika test gagal.
4. **Kualitas laporan:** finding ditulis jelas, ada dampak, PoC, dan rekomendasi.
5. **Kejujuran:** sumber dan hint dicatat apa adanya.

---

## 📁 Struktur Repositori

```text
challenge-ug-blockchain/
├── README.md                   ← kamu di sini (aturan & tata cara)
├── .github/
│   └── pull_request_template.md
└── ug-challenge-1/             ← satu folder = satu challenge (proyek Foundry mandiri)
    ├── README.md               ← soal dan materi challenge
    ├── foundry.toml
    ├── src/                    ← kontrak yang diaudit (JANGAN diubah)
    ├── lib/forge-std/          ← submodule
    └── submissions/
        ├── _template/          ← salin folder ini
        └── <username>/         ← pekerjaanmu
```

---

## ❓ Troubleshooting

| Masalah | Solusi |
|---|---|
| `Source "forge-std/Test.sol" not found` | Submodule belum terunduh. Jalankan `git submodule update --init --recursive`. |
| `forge: command not found` | Jalankan `foundryup`, lalu buka ulang terminal. |
| Test orang lain ikut berjalan | Gunakan `--match-path "submissions/<username>/*"`. |
| Test orang lain gagal dikompilasi sehingga punyamu ikut gagal | Sinkronkan `main` terbaru. Kalau masih gagal, laporkan ke mentor. |
| Bingung harus mulai dari mana | Baca bagian **Part 0 — Belajar Dulu** di README challenge. |

---

Selamat berburu bug. 🐛🔍
