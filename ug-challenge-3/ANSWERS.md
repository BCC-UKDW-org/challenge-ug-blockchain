# Jawaban — Challenge 03: Lucky Draw I

- **Nama:** 
- **GitHub:** @

> Tulis dengan kata-katamu sendiri. Jawaban yang tidak bisa kamu jelaskan saat tanya jawab dianggap tidak valid.

---

## Part A — Scoping & Recon

**A1 — Alur uang:**

```text
(gambar/tabel ke mana ETH bergerak di setiap fungsi)
```

**A2 — Tabel efek fungsi:**

| Fungsi | State yang berubah | External call (sebelum/sesudah ubah state?) | Siapa yang boleh memanggil |
|---|---|---|---|
| `enter()` |  |  |  |
| `refund(index)` |  |  |  |
| `drawWinner(seed)` |  |  |  |
| `claimPrize()` |  |  |  |
| `withdrawFees()` |  |  |  |

**A3 — Persamaan pembukuan (kondisi normal):**

```text
address(this).balance == ...
```

**A4 — Asumsi developer (minimal 3) dan mana yang bisa dilanggar:**

1. 
2. 
3. 

---

## Part B — `refund()`

**B1.1 — Kode apa yang berjalan ketika ETH dikirim ke kontrak?**

**B1.2 — Nilai `players[playerIndex]` saat itu, dan apakah `require` masih lolos?**

**B1.3 — ETH maksimal yang bisa diambil dengan satu tiket:**

**Penjelasan kontrak penyerang (baris per baris):**

**Kapan penyerang berhenti, dan kenapa harus berhenti?**

**Output `forge test --match-test test_PoC -vvvv` (potongan trace yang menunjukkan refund berulang):**

```text
```

---

## Part C — `withdrawFees()`

**C1.1 — Cara ETH masuk tanpa memanggil fungsi kontrak:**

**C1.2 — Dampak 1 wei paksa, dan apakah bisa dipulihkan:**

**C1.3 — Siapa pelakunya dan berapa biayanya:**

**Apa yang masih dilakukan `selfdestruct` setelah EIP-6780, dan apa yang tidak lagi dilakukan:**

**Kenapa PoC "revert saat undian masih berjalan" BUKAN bukti bug:**

---

## Part D — Mitigasi

**Dua cara memperbaiki `refund()` dan kelebihan masing-masing:**

1. 
2. 

**Kenapa `>=` masih kurang tepat untuk `withdrawFees()`, dan sumber kebenaran yang lebih baik:**

**Output akhir `./check.sh`:**

```text
```

---

## Hint yang Dibuka

Jujur saja, membuka hint tidak mengurangi nilai.

| Part | Hint 1 | Hint 2 | Hint 3 |
|---|---|---|---|
| A | ☐ | — | — |
| B | ☐ | ☐ | ☐ |
| C | ☐ | ☐ | ☐ |
| D | ☐ | — | — |

## Referensi yang Dipakai

- 
