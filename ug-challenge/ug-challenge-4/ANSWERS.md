# Jawaban — Challenge 04: Lucky Draw II

- **Nama:** 
- **GitHub:** @

> Tulis dengan kata-katamu sendiri. Jawaban yang tidak bisa kamu jelaskan saat tanya jawab dianggap tidak valid.

---

## Tabel Fungsi

| Fungsi | State yang berubah | ETH masuk/keluar | Siapa yang boleh memanggil | Bergantung pada jumlah pemain? |
|---|---|---|---|---|
| `enter()` |  |  |  |  |
| `drawWinner()` |  |  |  |  |
| `claimPrize()` |  |  |  |  |
| `withdrawFees()` |  |  |  |  |

---

## Part A — Recon & Static Analysis

**A1 — Warning/lint dari `forge build` dan artinya:**

```text
(tempel di sini)
```

**A2 — Triase hasil Slither / Aderyn:**

| Temuan tool | True positive / False positive / Informational | Alasan |
|---|---|---|
|  |  |  |

**A3.1 — Biaya gas `enter()` pemain ke-10 vs ke-1000:**

**A3.2 — Siapa yang bisa memengaruhi/mengetahui input `drawWinner()`:**

**A3.3 — Nilai maksimum `uint64` dalam ether, dan jumlah pemain minimal agar fee melebihinya:**

---

## Part B — Biaya Gas `enter()`

**Penjelasan desain PoC (kenapa membandingkan dua pengukuran):**

**B2.1 — Angka gas yang diukur dan rasionya:**

```text
gas batch pertama: 
gas batch kedua  : 
```

**B2.2 — Kaitan dengan block gas limit:**

**B2.3 — Bagaimana penyerang memanfaatkannya:**

---

## Part C — Seberapa Acak `drawWinner()`?

**Penjelasan langkah PoC (bagaimana penyerang memprediksi pemenang):**

**C2.1 — Siapa yang bisa memilih/mengetahui setiap input:**

| Input | Bisa dipilih oleh | Bisa diketahui sebelumnya oleh |
|---|---|---|
| `msg.sender` |  |  |
| `block.timestamp` |  |  |
| `block.prevrandao` |  |  |

**C2.2 — Kenapa "siapa saja boleh memanggil `drawWinner()`" memperparah masalah:**

**C2.3 — Solusi yang benar, dan kenapa menambah variabel blok lain tidak cukup:**

---

## Part D — Pembukuan Fee

**D1 — Hitungan manual (100 pemain, `entranceFee = 1 ether`):**

| Besaran | Nilai |
|---|---|
| Total tiket |  |
| Hadiah pemenang (80%) |  |
| Fee owner (20%) |  |
| `type(uint64).max` (wei / ether) |  |

**D2.1 — Nilai `totalFees` sebenarnya dan perhitungannya:**

**D2.2 — Kenapa tidak revert padahal Solidity ≥0.8:**

**D2.3 — Ke mana selisih fee pergi:**

---

## Part E — Laporan

Lihat `FINDINGS.md`.

---

## Hint yang Dibuka

Jujur saja. Membuka hint itu wajar, yang penting kamu paham alasannya.

| Part | Hint 1 | Hint 2 | Hint 3 |
|---|---|---|---|
| B | ☐ | ☐ | ☐ |
| C | ☐ | ☐ | ☐ |
| D | ☐ | ☐ | ☐ |

## Referensi yang Dipakai

- 
