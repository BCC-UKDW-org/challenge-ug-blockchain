# 📚 Resource Learn Audit

Kumpulan sumber untuk **mencari database audit, laporan bug, dan materi belajar** keamanan smart contract. Gunakan halaman ini sebagai "perpustakaan" saat mengerjakan challenge di [`ug-challenge/`](../ug-challenge/) maupun setelahnya.

> **Cara terbaik memakai sumber ini:** setiap kali menemukan bug di sebuah challenge, cari bug **sejenis** di database di bawah ini. Bandingkan cara auditor profesional menjelaskan, membuktikan, dan menilai severity-nya dengan `FINDINGS.md` milikmu.
>
> ⚠️ Jangan memakai database ini untuk mencari jawaban challenge yang **sedang** kamu kerjakan. Pakai untuk belajar pola, bukan menyalin.

---

## Daftar Isi

1. [Database finding](#1--database-finding)
2. [Laporan audit dari firma keamanan](#2--laporan-audit-dari-firma-keamanan)
3. [Database hack nyata](#3--database-hack-nyata)
4. [Checklist & heuristik audit](#4--checklist--heuristik-audit)
5. [Katalog kerentanan & pola Solidity](#5--katalog-kerentanan--pola-solidity)
6. [CTF & latihan](#6--ctf--latihan)
7. [Blog & peneliti keamanan](#7--blog--peneliti-keamanan)
8. [Kumpulan link (awesome list)](#8--kumpulan-link-awesome-list)
9. [Bug bounty](#9--bug-bounty)
10. [Rutinitas belajar yang disarankan](#10--rutinitas-belajar-yang-disarankan)

---

## 1. 🔎 Database finding

Tempat mencari finding berdasarkan **kategori bug** (misalnya reentrancy, oracle manipulation, storage collision).

| Sumber | Isi |
|---|---|
| [Solodit](https://solodit.cyfrin.io/) | Dataset ribuan finding dari audit sungguhan. Bisa difilter berdasarkan kategori, severity, protokol, dan firma audit. **Mulai dari sini.** |
| [0xSimao — Findings Database](https://0xsimao.com/findings) | Ratusan finding dari puluhan audit dan kompetisi milik satu auditor, lengkap dengan severity dan write-up. |
| [Code4rena Reports](https://code4rena.com/reports) | Laporan akhir dari audit kompetitif Code4rena. |
| [Sherlock Contests](https://audits.sherlock.xyz/contests) | Daftar kontes audit Sherlock beserta temuannya. |
| [Cantina Portfolio](https://cantina.xyz/portfolio) | Laporan security review dari Cantina. |
| [CodeHawks](https://codehawks.cyfrin.io/) | Audit kompetitif (termasuk **First Flights** untuk pemula) beserta hasilnya. |

---

## 2. 📄 Laporan audit dari firma keamanan

Contoh laporan audit **lengkap**: dari scope, metodologi, sampai daftar finding. Cocok untuk melihat format laporan profesional.

| Firma | Link |
|---|---|
| Cyfrin | [Cyfrin/cyfrin-audit-reports](https://github.com/Cyfrin/cyfrin-audit-reports) |
| Trail of Bits | [trailofbits/publications](https://github.com/trailofbits/publications) |
| OpenZeppelin | [OpenZeppelin — Security Audits](https://blog.openzeppelin.com/security-audits) |
| ConsenSys Diligence | [Diligence — Audits](https://diligence.consensys.io/audits/) |
| Spearbit | [spearbit/portfolio](https://github.com/spearbit/portfolio) |
| Zellic | [Zellic/publications](https://github.com/Zellic/publications) |
| Pashov Audit Group | [pashov/audits](https://github.com/pashov/audits) |
| Sigma Prime | [sigp/public-audits](https://github.com/sigp/public-audits) |
| ChainSecurity | [ChainSecurity — Audit Reports](https://www.chainsecurity.com/smart-contract-audit-reports) |
| Halborn | [Halborn — Audits](https://www.halborn.com/audits) |
| Runtime Verification | [runtimeverification/publications](https://github.com/runtimeverification/publications) |
| Sherlock | [sherlock-protocol/sherlock-reports](https://github.com/sherlock-protocol/sherlock-reports) |

---

## 3. 💥 Database hack nyata

Belajar dari protokol yang **benar-benar** kebobolan: apa bug-nya, berapa kerugiannya, dan bagaimana serangannya berjalan.

| Sumber | Isi |
|---|---|
| [Rekt — Leaderboard](https://rekt.news/leaderboard) | Peringkat hack DeFi terbesar beserta analisis kasusnya. |
| [DeFiHackLabs](https://github.com/SunWeb3Sec/DeFiHackLabs) | Ratusan hack nyata yang direproduksi sebagai **test Foundry**. Formatnya sangat mirip dengan PoC yang kamu tulis di challenge. |
| [SlowMist Hacked](https://hacked.slowmist.io/) | Database insiden hack blockchain dari SlowMist. |
| [DeFiLlama — Hacks](https://defillama.com/hacks) | Daftar hack DeFi beserta jumlah kerugian dan teknik serangannya. |
| [BlockThreat](https://www.blockthreat.io/) | Newsletter mingguan berisi insiden, riset, dan tools keamanan blockchain. |
| [Coinspect — Learn EVM Attacks](https://github.com/coinspect/learn-evm-attacks) | Reproduksi serangan EVM nyata dengan penjelasan langkah demi langkah. |

---

## 4. ✅ Checklist & heuristik audit

Daftar pertanyaan yang biasa diajukan auditor saat membaca kode.

| Sumber | Isi |
|---|---|
| [Solodit Checklist](https://solodit.cyfrin.io/checklist) | Checklist audit interaktif yang disusun dari finding nyata. |
| [Cyfrin — Audit Checklist](https://github.com/Cyfrin/audit-checklist) | Kumpulan checklist audit dalam format repo. |
| [0x3b — The 6-step checklist](https://paragraph.com/@0x3b/audit-checklist) | Checklist kesiapan audit untuk tim protokol. Berguna untuk memahami apa yang membuat kode "siap diaudit". |
| [Smart Contract Auditing Heuristics](https://github.com/OpenCoreCH/smart-contract-auditing-heuristics) | Heuristik praktis untuk menemukan bug saat review. |
| [SCSVS](https://github.com/ComposableSecurity/SCSVS) | Smart Contract Security Verification Standard: standar verifikasi keamanan per kategori. |
| [Nascent — Simple Security Toolkit](https://github.com/nascentxyz/simple-security-toolkit) | Panduan praktis keamanan untuk tim pengembang. |
| [C4 Common Issues](https://github.com/byterocket/c4-common-issues) | Kumpulan isu yang sering muncul di audit Code4rena beserta perbaikannya. |

---

## 5. 📖 Katalog kerentanan & pola Solidity

| Sumber | Isi |
|---|---|
| [Smart Contract Vulnerabilities](https://github.com/kadenzipfel/smart-contract-vulnerabilities) | Katalog jenis kerentanan smart contract beserta penjelasannya. |
| [Not So Smart Contracts](https://github.com/crytic/not-so-smart-contracts) | Contoh kode rentan dari Trail of Bits (crytic), per jenis bug. |
| [Useful Solidity Patterns](https://github.com/dragonfly-xyz/useful-solidity-patterns) | Pola Solidity yang sering dipakai (dan disalahgunakan) dari Dragonfly. Penting untuk memahami kode yang kamu audit. |
| [Secureum Mind Map](https://github.com/x676f64/secureum-mind_map) | Rangkuman materi Secureum Epoch 0: keamanan Solidity, EVM, dan pola audit. |
| [Secureum](https://secureum.substack.com/) | Materi dan tulisan keamanan smart contract dari Secureum. |

---

## 6. 🎮 CTF & latihan

Latihan menyerang kontrak rentan secara langsung. Kerjakan setelah menyelesaikan UG-1 sampai UG-8.

| Sumber | Isi |
|---|---|
| [Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/) | Challenge DeFi berbasis Foundry: flash loan, oracle, governance, proxy, dan lainnya. |
| [Ethernaut](https://ethernaut.openzeppelin.com/) | Challenge Solidity per level dari OpenZeppelin, langsung di browser. |
| [Mr Steal Yo Crypto](https://mrstealyocrypto.xyz) | CTF untuk belajar offensive security smart contract. |
| [BuidlGuidl CTF](https://ctf.buidlguidl.com/) | CTF berisi tantangan coding Ethereum yang seru. |
| [Capture the Ether](https://www.capturetheether.com/) | CTF klasik keamanan smart contract. Beberapa tools-nya sudah lama, jadi kerjakan setelah yang lain. |

---

## 7. 📝 Blog & peneliti keamanan

| Sumber | Isi |
|---|---|
| [Joran Honig](https://joranhonig.nl/) | Blog peneliti keamanan independen (Spearbit, Immunefi). |
| [0xSimao](https://0xsimao.com/findings) | Portofolio dan database finding seorang auditor kompetitif. |
| [Zellic — Blog](https://www.zellic.io/blog/) | Riset keamanan mendalam dari Zellic. |

---

## 8. 📦 Kumpulan link (awesome list)

Kalau ingin menjelajah lebih jauh, kumpulan ini berisi ratusan link lain.

| Sumber | Isi |
|---|---|
| [Immunefi — Web3 Security Library](https://github.com/immunefi-team/Web3-Security-Library) | Pustaka materi keamanan web3 dari Immunefi. |
| [Awesome Web3 Security](https://github.com/Anugrahsr/Awesome-web3-Security) | Kumpulan materi dan resource keamanan web3. |
| [Smart Contract Auditor Tools & Techniques](https://github.com/shanzson/Smart-Contract-Auditor-Tools-and-Techniques) | Daftar tools dan teknik yang dipakai auditor. |
| [Blockchain Security Audit List](https://github.com/0xNazgul/Blockchain-Security-Audit-List) | Daftar firma audit beserta laporan publiknya. |
| [DeFi Developer Road Map](https://github.com/OffcierCia/DeFi-Developer-Road-Map) | Roadmap dan kumpulan materi untuk developer DeFi, termasuk bagian keamanan. |

---

## 9. 🏆 Bug bounty

| Sumber | Isi |
|---|---|
| [Immunefi — Bug Bounty Programs](https://immunefi.com/bug-bounty/) | Program bug bounty resmi untuk protokol yang sudah live. |

> ⚠️ **Etika:** uji keamanan hanya pada program bug bounty **resmi** dan patuhi aturan (scope) masing-masing program. Jangan pernah menguji serangan pada protokol live di luar program tersebut.

---

## 10. 📅 Rutinitas belajar yang disarankan

1. **Setiap hari (15 menit):** buka [Solodit](https://solodit.cyfrin.io/), baca 2–3 finding dengan severity High.
2. **Setiap minggu:** baca satu analisis kasus di [Rekt](https://rekt.news/leaderboard), lalu cari reproduksinya di [DeFiHackLabs](https://github.com/SunWeb3Sec/DeFiHackLabs) dan jalankan test-nya.
3. **Setelah menyelesaikan sebuah challenge:** cari 3 finding sejenis di Solodit atau [0xSimao](https://0xsimao.com/findings), lalu perbaiki `FINDINGS.md` milikmu.
4. **Setelah UG-8:** kerjakan [Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/), lalu ikuti [CodeHawks First Flights](https://codehawks.cyfrin.io/). Lihat juga [09 — Lanjut Belajar](../ug-challenge/ug-challenge-9/).

---

Punya sumber bagus lain? Tambahkan ke daftar ini. Pastikan link-nya aktif dan sumbernya terpercaya.
