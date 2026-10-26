# 09 — Lanjut Belajar

Selamat! Kalau kamu sudah menyelesaikan [UG-1 sampai UG-8](../README.md#️-daftar-challenge) dan bisa menjelaskan setiap baris test-mu, kamu sudah punya fondasi seorang auditor smart contract:

- menulis **fuzz test** dan **invariant test** dengan handler,
- membaca kode dengan curiga dan membandingkannya dengan dokumentasi,
- membuktikan bug dengan **Proof of Code**,
- menulis **finding** dengan format laporan audit profesional.

Halaman ini berisi langkah berikutnya. Tidak ada `check.sh` di sini. Mulai sekarang, yang menilai pekerjaanmu adalah dunia nyata.

> Aturan AI tetap berlaku: pakai AI seperti Google untuk mencari dokumentasi dan konsep, bukan untuk mengerjakan. Di audit kompetitif, temuan hasil copy-paste AI tanpa pemahaman biasanya **invalid** dan merusak reputasimu.

---

## 🧭 Urutan yang Disarankan

```text
 1. Selesaikan materi Updraft yang tersisa
        ↓
 2. Latihan challenge: Damn Vulnerable DeFi, Ethernaut
        ↓
 3. Baca laporan audit sungguhan: Solodit, Cyfrin Audit Reports
        ↓
 4. Audit kompetitif pertama: CodeHawks First Flights
        ↓
 5. Audit kompetitif & bug bounty: CodeHawks, Code4rena, Sherlock, Cantina, Immunefi
```

---

## 1. 📺 Lanjutkan Cyfrin Updraft

| Materi | Kenapa penting |
|---|---|
| [Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **MEV & Governance** | Front-running, sandwich attack, dan serangan governance. Belum dibahas di UG-1 sampai UG-8. |
| [Smart Contract Security](https://updraft.cyfrin.io/courses/security), section **Vault Guardians** | Audit akhir dengan codebase besar ([repo](https://github.com/Cyfrin/8-vault-guardians-audit)). Latihan menyusun laporan audit lengkap. |
| [Assembly and Formal Verification](https://updraft.cyfrin.io/courses/formal-verification) | Membaca Yul/assembly dan membuktikan properti kontrak secara matematis. |
| [Repo course Smart Contract Security](https://github.com/Cyfrin/security-and-auditing-full-course-s23) | Semua codebase, catatan, dan exercise dari course. |

---

## 2. 🎮 Latihan Challenge

| Sumber | Isi | Cocok untuk |
|---|---|---|
| [Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/) | Challenge DeFi berbasis Foundry: flash loan, oracle, governance, proxy, dan lainnya. | Lanjutan langsung dari UG-5 sampai UG-8. |
| [Ethernaut](https://ethernaut.openzeppelin.com/) | Challenge Solidity per level dari OpenZeppelin, langsung di browser. | Menguatkan dasar: reentrancy, storage, `delegatecall`, dan lainnya. |
| [DeFiHackLabs](https://github.com/SunWeb3Sec/DeFiHackLabs) | Ratusan reproduksi hack DeFi nyata dalam bentuk test Foundry. | Belajar dari kasus nyata, sangat mirip dengan PoC yang kamu tulis di sini. |

**Tips:** kerjakan dengan cara yang sama seperti di repo ini. Tulis PoC sendiri, catat penjelasannya, dan jangan buka solusi sebelum benar-benar mentok.

---

## 3. 📖 Baca Laporan Audit Sungguhan

| Sumber | Isi |
|---|---|
| [Solodit](https://solodit.cyfrin.io/) | Database ribuan finding dari audit sungguhan. Cari berdasarkan kategori bug (misalnya "oracle manipulation", "storage collision") untuk studi kasus. |
| [Solodit Checklist](https://solodit.cyfrin.io/checklist) | Checklist pertanyaan audit yang disusun dari finding nyata. |
| [Cyfrin Audit Reports](https://github.com/Cyfrin/cyfrin-audit-reports) | Laporan audit lengkap dari tim Cyfrin. Contoh format laporan yang baik. |
| [Code4rena Reports](https://code4rena.com/reports) | Laporan dari audit kompetitif publik. |
| [Rekt News](https://rekt.news/) | Analisis hack besar di dunia nyata. |

**Latihan:** pilih satu finding di Solodit dengan kategori yang sama seperti salah satu temuanmu di UG-1 sampai UG-8, lalu bandingkan cara penulisannya dengan `FINDINGS.md` milikmu. Apa yang bisa kamu perbaiki?

---

## 4. 🐣 Audit Kompetitif Pertama: CodeHawks First Flights

[CodeHawks First Flights](https://codehawks.cyfrin.io/first-flights) adalah audit kompetitif **tingkat pemula** dengan codebase kecil, sangat cocok sebagai tugas setelah menyelesaikan repo ini.

Cara mengerjakannya mirip dengan challenge di sini:

1. Baca dokumentasi dan kode (recon), seperti Part A di setiap challenge.
2. Cari bug, lalu buktikan dengan PoC Foundry.
3. Tulis finding dengan format yang sudah kamu latih di `FINDINGS.md`.
4. Setelah kontes selesai, bandingkan temuanmu dengan hasil resmi. Bug apa yang terlewat? Kenapa?

---

## 5. 🏆 Audit Kompetitif & Bug Bounty

Kalau sudah konsisten menemukan bug di First Flights, coba platform berikut:

| Platform | Jenis |
|---|---|
| [CodeHawks](https://codehawks.cyfrin.io/) | Audit kompetitif |
| [Code4rena](https://code4rena.com/) | Audit kompetitif |
| [Sherlock](https://www.sherlock.xyz/) | Audit kompetitif |
| [Cantina](https://cantina.xyz/) | Audit kompetitif & bug bounty |
| [Immunefi](https://immunefi.com/) | Bug bounty untuk protokol yang sudah live |

> ⚠️ **Etika:** bug bounty hanya untuk program yang **resmi** dan sesuai aturan (scope) masing-masing program. Jangan pernah menguji serangan di protokol live di luar program tersebut.

---

## 📚 Bacaan Tambahan

| Sumber | Isi |
|---|---|
| [Trail of Bits — Building Secure Contracts](https://secure-contracts.com/) | Panduan keamanan, fuzzing (Echidna, Medusa), dan checklist ([repo](https://github.com/crytic/building-secure-contracts)). |
| [RareSkills](https://www.rareskills.io/) | Artikel mendalam tentang Solidity, EVM, dan keamanan. |
| [SWC Registry](https://swcregistry.io/) | Klasifikasi kelemahan smart contract yang umum (sudah tidak aktif diperbarui, tetapi masih bagus untuk dasar). |
| [Ethereum-Jakarta/fullstack-web3-roadmap](https://github.com/Ethereum-Jakarta/fullstack-web3-roadmap) | Roadmap belajar fullstack web3 dari komunitas Indonesia. |

Daftar tools audit (Slither, Aderyn, Echidna, Halmos, dan lainnya) ada di [README utama](../README.md#-tools-yang-membantu-audit).

---

## 🙏 Penutup

Auditor yang baik tidak lahir dari satu repo. Mereka lahir dari kebiasaan: membaca kode setiap hari, menulis PoC untuk setiap dugaan, dan terus belajar dari bug yang terlewat.

Selamat berburu bug. 🐛🔍
