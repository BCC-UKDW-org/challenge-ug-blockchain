# Jawaban — Challenge 06: Flash Lender

- **Nama:** 
- **GitHub:** @

> Tulis dengan kata-katamu sendiri. Jawaban yang tidak bisa kamu jelaskan saat tanya jawab dianggap tidak valid.

---

## Tabel Fungsi

| Fungsi | Mengubah `totalAssets`? | Mengubah `totalShares`? | Saldo WETH lender berubah? | External call? |
|---|---|---|---|---|
| `deposit` |  |  |  |  |
| `redeem` |  |  |  |  |
| `flashLoan` |  |  |  |  |

---

## Part A — Flash Loan yang Jujur

**Desain `HonestReceiver` (dari mana WETH untuk membayar fee?):**

**A.1 — Urutan eksekusi `flashLoan` baris per baris:**

**A.2 — Apa yang terjadi kalau dana tidak dikembalikan? (tempel test & output)**

```text
```

**A.3 — Assertion yang membuktikan fee milik LP, dan kenapa "tidak revert" tidak cukup:**

---

## Part B — Audit `FlashLender`

**B.1 — Alur serangan langkah demi langkah:**

| Langkah | Aksi | `totalAssets` | `totalShares` | Saldo WETH lender |
|---|---|---|---|---|
| 0 | Kondisi awal | 1000 WETH | 1000 | 1000 WETH |
| 1 |  |  |  |  |

**B.2 — Kenapa pengecekan saldo tidak cukup:**

**B.3 — Keuntungan bersih penyerang dan asalnya:**

---

## Part C — Audit `CollateralLoan`

**C.1 — Harga TKN sebelum & sesudah manipulasi (dengan perhitungan constant product):**

**C.2 — Siapa yang rugi dan berapa bad debt-nya:**

**C.3 — Kenapa kerugian terjadi walaupun `SimpleAMM` tidak punya bug:**

---

## Part D — Laporan & Diskusi

Temuan lengkap: lihat `FINDINGS.md`.

**D.1 — Dua cara memperbaiki `FlashLender` (kelebihan & kekurangan):**

1. 
2. 

**D.2 — TWAP vs Chainlink. Apakah TWAP kebal manipulasi?**

**D.3 — Akar masalah Part C: flash loan atau oracle?**

**D.4 — Alasan severity setiap temuan:**

---

## Hint yang Dibuka

Jujur saja. Membuka hint itu wajar, yang penting kamu paham alasannya.

| Part | Hint 1 | Hint 2 | Hint 3 |
|---|---|---|---|
| A | ☐ | ☐ | ☐ |
| B | ☐ | ☐ | ☐ |
| C | ☐ | ☐ | ☐ |

## Referensi yang Dipakai

- 
