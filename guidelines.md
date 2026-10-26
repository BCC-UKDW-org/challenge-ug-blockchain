# Panduan Lengkap UG Blockchain Challenges

Panduan ini untuk kamu yang **baru pertama kali** belajar web3 atau audit smart contract. Ikuti nomornya **berurutan dari 1 sampai selesai**. Jangan lompat, karena setiap langkah menyiapkan langkah berikutnya.

> Butuh ringkasan aturan, daftar challenge, dan tools? Lihat [README utama](./README.md).

---

## Bagian A — Kenalan Dulu

1. **Pahami apa yang akan kamu lakukan.**
   Kamu akan berperan sebagai **auditor smart contract**, yaitu orang yang memeriksa kode program di blockchain untuk mencari celah keamanan **sebelum** dimanfaatkan penjahat. Di setiap challenge, kamu diberi sebuah smart contract yang punya bug tersembunyi. Tugasmu: menemukan bug itu dan **membuktikannya dengan test**.

2. **Kenali istilah-istilah dasar.** Tidak perlu hafal sekarang. Kembali ke tabel ini kapan saja kalau bingung.

   | Istilah | Artinya (versi sederhana) |
   |---|---|
   | **Blockchain** | Buku catatan bersama yang tidak bisa diubah diam-diam. Semua orang bisa membacanya. |
   | **Smart contract** | Program yang berjalan di blockchain. Sekali di-deploy, kodenya tidak bisa diubah. |
   | **Solidity** | Bahasa pemrograman untuk menulis smart contract di Ethereum. File-nya berakhiran `.sol`. |
   | **ETH / wei** | ETH adalah mata uang Ethereum. 1 ETH = 1.000.000.000.000.000.000 wei (10¹⁸ wei). |
   | **Token (ERC20)** | "Koin" yang dibuat lewat smart contract, misalnya USDT. |
   | **Bug / celah** | Kesalahan di kode yang membuat kontrak bekerja tidak sesuai harapan, misalnya dana bisa dicuri. |
   | **Foundry** | Kumpulan tools untuk meng-compile dan menguji smart contract. Perintah utamanya `forge`. |
   | **Test** | Kode kecil yang memeriksa apakah kontrak berperilaku benar. Ditulis juga dalam Solidity. |
   | **Fuzz test** | Test yang dijalankan ratusan kali dengan input acak, untuk mencari input yang membuat kontrak rusak. |
   | **Invariant** | Aturan yang **harus selalu benar**, misalnya "total saldo semua pengguna = total dana di vault". |
   | **PoC (Proof of Code)** | Test yang membuktikan sebuah bug benar-benar ada dan bisa dimanfaatkan. |
   | **Finding** | Laporan tertulis tentang satu bug: apa masalahnya, seberapa parah, buktinya, dan cara memperbaikinya. |
   | **Terminal** | Jendela tempat kamu mengetik perintah, misalnya `forge test`. |
   | **Repo / clone** | Repo adalah folder proyek di GitHub. Clone artinya mengunduh repo itu ke laptopmu. |

3. **Pahami aturan main sebelum mulai.**
   - **AI hanya boleh dipakai seperti Google.** Boleh bertanya konsep atau mencari dokumentasi ("apa itu `vm.prank`?"). **Dilarang** meminta AI menuliskan test, mencari bug di kode challenge, atau menulis laporanmu.
   - **Setiap baris kode harus bisa kamu jelaskan.** Saat praktikum, mentor bisa memintamu menjelaskannya.
   - **Jangan menyalin** pekerjaan teman, dan jangan membuka isi file `.check-data` (isinya kunci jawaban yang disamarkan).

   Aturan lengkapnya ada di [README — Aturan Utama](./README.md#️-aturan-utama--wajib-dibaca).

---

## Bagian B — Menyiapkan Laptop (cukup sekali)

4. **Buka terminal sesuai sistem operasimu.**
   - **macOS:** tekan `Cmd + Spasi`, ketik **Terminal**, lalu Enter.
   - **Linux:** buka aplikasi Terminal.
   - **Windows:** kamu perlu **WSL** (Linux di dalam Windows). Buka **PowerShell sebagai Administrator**, jalankan `wsl --install`, lalu **restart** laptop. Setelah itu buka aplikasi **Ubuntu** dari Start Menu dan buat username serta password. **Mulai sekarang, semua perintah diketik di terminal Ubuntu**, bukan di PowerShell.

5. **Install Git dan curl.**
   - **macOS:** jalankan `xcode-select --install`, lalu ikuti jendela instalasi yang muncul.
   - **Linux / WSL:** jalankan `sudo apt update && sudo apt install -y git curl`.

   ✅ **Berhasil kalau** perintah `git --version` menampilkan versi, misalnya `git version 2.43.0`.

6. **Install Foundry.** Jalankan:

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   ```

   Lalu **tutup terminal dan buka terminal baru**, kemudian jalankan:

   ```bash
   foundryup
   ```

   ✅ **Berhasil kalau** perintah `forge --version` menampilkan `forge Version: 1.x.x-stable`.

7. **Unduh (clone) repo ini ke laptopmu.**

   ```bash
   git clone --recurse-submodules --shallow-submodules https://github.com/BCC-UKDW-org/challenge-ug-blockchain.git
   cd challenge-ug-blockchain
   ```

   Ukurannya sekitar 15 MB. Kalau kamu lupa menulis `--recurse-submodules`, jalankan ini dari dalam folder repo:

   ```bash
   git submodule update --init --recursive --depth 1
   ```

8. **Uji coba instalasi.** Masuk ke challenge pertama dan jalankan tiga perintah ini satu per satu:

   ```bash
   cd ug-challenge-1
   forge build
   forge test
   ./check.sh
   ```

   ✅ **Semuanya normal kalau:**
   - `forge build` menampilkan `Compiler run successful!` (pertama kali akan mengunduh compiler, tunggu sebentar).
   - `forge test` menampilkan `No tests found in project!`, karena kamu memang belum menulis test.
   - `./check.sh` menampilkan beberapa ❌ dengan pesan **"tidak ditemukan"**, karena test-mu belum ada. Yang penting tidak ada pesan error lain.

9. **Buka proyek di VS Code.** Dari folder repo, jalankan `code .`, lalu pasang extension **Solidity** supaya kode berwarna dan mudah dibaca. Pengguna Windows: pasang juga extension **WSL**.

   🎉 **Laptopmu sudah siap.** Langkah 4–9 tidak perlu diulang lagi.

---

## Bagian C — Pemanasan: Test Pertamamu

10. **Kenali isi folder challenge.** Setiap folder `ug-challenge-N` berisi:

    | Isi | Kegunaan | Boleh diubah? |
    |---|---|---|
    | `README.md` | Soal, materi yang wajib ditonton, dan hint. | Tidak |
    | `src/` | Smart contract yang kamu audit. | **Jangan diubah** |
    | `test/` | Tempat kamu menulis test. Sudah ada file kerangkanya. | **Ya, di sini kamu bekerja** |
    | `ANSWERS.md` | Tempat menulis jawaban dan penjelasanmu. | Ya |
    | `FINDINGS.md` | Tempat menulis laporan bug. | Ya |
    | `check.sh` | Pemeriksa otomatis jawabanmu. | Tidak |

11. **Tulis test pertamamu.** Buka `ug-challenge-1/test/SimpleVault.t.sol`, lalu tambahkan kode ini tepat di bawah tulisan `// TULIS TEST KAMU DI SINI`:

    ```solidity
    function test_Pemanasan() public view {
        assertEq(vault.totalDeposits(), 0);
    }
    ```

    Artinya: "Saya yakin total deposit di vault yang baru dibuat adalah 0."

12. **Jalankan test-nya.**

    ```bash
    forge test --match-test test_Pemanasan -vvv
    ```

    ✅ **Berhasil kalau** muncul `[PASS] test_Pemanasan()`.

13. **Lihat seperti apa test yang gagal.** Ganti angka `0` menjadi `1`, lalu jalankan lagi perintah di langkah 12. Akan muncul:

    ```text
    [FAIL: assertion failed: 0 != 1] test_Pemanasan()
    ```

    Artinya: nilai sebenarnya `0`, tetapi kamu mengharapkan `1`. Setelah paham, **hapus fungsi pemanasan ini** supaya file test kembali bersih.

---

## Bagian D — Mengerjakan Sebuah Challenge

Ulangi langkah 14–23 untuk setiap challenge, mulai dari **UG-1**, lalu UG-2, dan seterusnya sampai **UG-8**.

14. **Masuk ke folder challenge dan buka README-nya.**

    ```bash
    cd ug-challenge-1      # ganti angkanya sesuai challenge
    ```

    Baca bagian **🎯 Misi Kamu** supaya tahu cerita protokolnya dan klaim developer yang harus kamu uji.

15. **Tonton materi Cyfrin Updraft di Part 0. Ini wajib.** Setiap README punya daftar video yang harus ditonton sebelum mengerjakan. Centang satu per satu. Tanpa materi ini, soalnya akan terasa sangat sulit.

16. **Jawab self-check.** Di akhir Part 0 ada beberapa pertanyaan. Kalau lebih dari dua yang belum bisa kamu jawab, tonton ulang materinya.

17. **Baca kontraknya dengan teliti.** Buka file di folder `src/`. Perhatikan komentar `/// @notice` dan `/// @dev`, karena di situlah developer menuliskan perilaku yang **seharusnya** terjadi. Bug adalah perbedaan antara yang seharusnya terjadi dan yang benar-benar terjadi.

18. **Kerjakan part demi part (A, B, C, …).** Setiap part di README berisi:
    - **Tugas:** apa yang harus kamu buat.
    - **Pertanyaan:** dijawab di `ANSWERS.md`.
    - **Nama test wajib:** gunakan nama fungsi persis seperti di tabel README, supaya `check.sh` bisa menemukannya.

19. **Tulis test di folder `test/`, lalu jalankan.**

    ```bash
    forge test -vvv                          # semua test
    forge test --match-test NAMA_TEST -vvv   # satu test saja
    forge test --match-test NAMA_TEST -vvvv  # dengan trace lengkap, untuk mencari penyebab error
    ```

    Cara membaca hasilnya:
    - `[PASS]` artinya semua `assert` di test itu terpenuhi.
    - `[FAIL: assertion failed: A != B]` artinya nilai sebenarnya `A`, sedangkan kamu mengharapkan `B`.
    - `[FAIL: <pesan>]` artinya ada transaksi yang revert (dibatalkan). Tambahkan `-vvvv` untuk melihat di mana.
    - `counterexample: ... args=[...]` artinya fuzzer menemukan input yang membuat test gagal.

20. **Periksa jawabanmu dengan `check.sh`.**

    ```bash
    ./check.sh B      # periksa Part B saja
    ./check.sh        # periksa semua part
    ```

    `check.sh` menjalankan test-mu pada **kontrak asli**, **kontrak yang bug-nya sudah diperbaiki**, dan **kontrak yang sengaja dirusak**. Test yang benar harus bisa membedakan ketiganya. Jadi **test hijau saja belum cukup**.

    | Kamu melihat | Artinya | Yang harus dilakukan |
    |---|---|---|
    | ✅ | Bagian ini sudah benar. | Lanjut. |
    | ❌ "tidak ditemukan" | Nama fungsi test belum ada atau salah ketik. | Samakan dengan tabel "Nama test wajib" di README. |
    | ❌ lainnya | Test-mu ada, tetapi belum menguji hal yang tepat. | Baca pesannya, lalu buka hint (langkah 21). |
    | ℹ️ | Informasi saja. | Baca, lalu lanjutkan. |

    Proses ini butuh 10–60 detik karena kontrak di-compile beberapa kali. Itu normal.

    Beberapa part (misalnya recon atau laporan) **tidak** dicek otomatis. Kalau kamu menjalankan `./check.sh` untuk part itu, akan muncul ℹ️ yang memberitahu bahwa part tersebut cukup dikerjakan di `ANSWERS.md` / `FINDINGS.md`.

21. **Kalau buntu, pakai bantuan dengan urutan ini:**
    1. Baca ulang tugas dan NatSpec kontrak.
    2. Buka **Hint 1** (arah) di README. Klik tulisan "💡 Hint" untuk membukanya.
    3. Tonton ulang video Updraft yang terkait dan baca dokumentasi di tabel "Dokumentasi pendamping".
    4. Buka **Hint 2** (konsep), lalu **Hint 3** (hampir jawaban) kalau masih buntu.
    5. Tanya **konsep** ke AI atau mesin pencari. Ingat aturannya: jangan tempel kode challenge dan jangan minta solusi.
    6. Tanya mentor saat praktikum.

    Catat hint mana saja yang kamu buka di tabel **"Hint yang Dibuka"** di `ANSWERS.md`. Membuka hint itu wajar dan tidak mengurangi nilai.

22. **Tulis penjelasan dan laporanmu.**
    - Di `ANSWERS.md`: jawab setiap pertanyaan dengan **kata-katamu sendiri**, dan jelaskan alasan setiap assertion di test-mu.
    - Di `FINDINGS.md`: tulis setiap bug dengan format **Title, Severity, Description, Impact, Proof of Concept, Recommended Mitigation**. Template-nya sudah tersedia di file tersebut.

23. **Pastikan semua beres sebelum pindah challenge.**
    - [ ] `./check.sh` menunjukkan semua ✅.
    - [ ] `ANSWERS.md` dan `FINDINGS.md` sudah terisi.
    - [ ] Kamu bisa menjelaskan setiap baris test-mu tanpa melihat catatan.

    Kalau ketiganya sudah, kembali ke langkah 14 untuk challenge berikutnya.

---

## Bagian E — Setelah Semua Selesai

24. **Simpan progresmu (opsional, tapi disarankan).** Kalau ingin menyimpan hasil kerjamu di GitHub sebagai portofolio, **fork** repo ini di GitHub, clone fork-mu, lalu simpan perubahan dengan:

    ```bash
    git add .
    git commit -m "selesai UG-1"
    git push
    ```

25. **Lanjutkan belajar.** Setelah UG-8 selesai, buka [**09 — Lanjut Belajar**](./ug-challenge-9/). Di sana ada langkah berikutnya: Damn Vulnerable DeFi, Solodit, CodeHawks First Flights, sampai audit kompetitif sungguhan.

---

## Kalau Ada Masalah

| Masalah | Solusi |
|---|---|
| `forge: command not found` | Tutup terminal, buka terminal baru, lalu jalankan `foundryup`. |
| `foundryup: command not found` | Buka terminal baru. Kalau masih gagal: `source ~/.bashrc` (Linux/WSL) atau `source ~/.zshenv` (macOS). |
| `Source "forge-std/Test.sol" not found` | Jalankan `git submodule update --init --recursive --depth 1` dari folder repo. |
| `./check.sh: Permission denied` | Jalankan `chmod +x check.sh`, atau pakai `bash check.sh`. |
| `$'\r': command not found` di Windows | Kamu meng-clone dari PowerShell. Clone ulang dari terminal **Ubuntu (WSL)**. |
| `check.sh`: "gagal dikompilasi terhadap versi kontrak pembanding" | Test-mu memakai sesuatu yang tidak ada di kontrak. Pakai hanya fungsi publik yang ada di `src/`. |
| Test-ku hijau tapi `check.sh` ❌ | Test-mu belum menguji hal yang tepat. Baca pesan ❌, lalu buka hint. |

Masalah lain? Lihat bagian **Troubleshooting** di [README utama](./README.md#-troubleshooting), atau tanyakan ke mentor.

---

Selamat belajar, dan selamat berburu bug! 🐛🔍
