# Jawaban — Challenge 05: Mini AMM

- **Nama:** 
- **GitHub:** @

> Tulis dengan kata-katamu sendiri. Jawaban yang tidak bisa kamu jelaskan saat tanya jawab dianggap tidak valid.

---

## Tugas Membaca

**1. Tabel efek fungsi**

| Fungsi | Reserve X | Reserve Y | `totalShares` | `swapCount` |
|---|---|---|---|---|
| `addLiquidity` |  |  |  |  |
| `removeLiquidity` |  |  |  |  |
| `swapExactInput` (X → Y) |  |  |  |  |
| `swapExactOutput` (X → Y) |  |  |  |  |

**2. Hitung manual** (reserve 100 X : 100 Y, Alice `swapExactInput(X, 10e18, ...)`):

- Y yang diterima Alice:
- `k` sebelum swap:
- `k` sesudah swap:

**3. Warning compiler dari `forge build` dan artinya:**

```text
(tempel warning di sini)
```

---

## Part A — Stateless Fuzzing

**A2.1 — Rentang input yang dipilih dan alasannya:**

**A2.2 — Test lulus. Apakah `MiniPool` aman? Bug jenis apa yang mustahil ditemukan test ini?**

---

## Part B — Invariant `x · y = k`

**Penjelasan desain handler (fungsi, `bound`, cara trader mendapat token):**

**B2.1 — Bagaimana invariant mengetahui `k` sebelum & sesudah swap?**

**B2.2 — Call sequence yang melanggar invariant:**

```text
(tempel di sini)
```

**Penjelasan langkah demi langkah & pola yang terlihat:**

**B2.3 — Kenapa Part A tidak bisa menemukan masalah ini?**

---

## Part C — Proof of Code

Untuk setiap temuan: apa yang dijanjikan NatSpec, apa yang sebenarnya terjadi, dan bagaimana PoC membuktikannya.

| # | Nama test PoC | Dijanjikan | Kenyataan |
|---|---|---|---|
| 1 |  |  |  |
| 2 |  |  |  |
| 3 |  |  |  |
| 4 |  |  |  |

**Bagaimana kamu memastikan setiap PoC fokus pada satu bug saja?**

---

## Part D — Diskusi Weird ERC20

**D2.1 — Fee-on-transfer:**

**D2.2 — Rebasing:**

**D2.3 — Token yang tidak mengembalikan `bool` (USDT):**

**D2.4 — ERC777 dan reentrancy:**

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
