# Jawaban — Challenge 07: Upgrade Trap

- **Nama:** 
- **GitHub:** @

> Tulis dengan kata-katamu sendiri. Jawaban yang tidak bisa kamu jelaskan saat tanya jawab dianggap tidak valid.

---

## Part A — Recon

**A1 — Alur panggilan `vault.stake{value: 1 ether}()`:**

1. 
2. 
3. 

**A2 — Storage layout:**

| Slot | StakingVaultV1 | StakingVaultV2 | Sama? |
|---|---|---|---|
| 0 |  |  |  |
| 1 |  |  |  |
| 2 |  |  |  |
| 3 |  |  |  |

**A3 — Kenapa alamat implementation disimpan di slot EIP-1967, bukan slot 0:**

**A4 — Daftar klaim keamanan:**

| Klaim | Sumber | Status (benar / salah / belum tahu) | Bukti |
|---|---|---|---|
|  |  |  |  |

---

## Part B — Inisialisasi

**B1.1 — Baris yang menegakkan "hanya sekali":**

**B1.2 — Apa yang bisa dilakukan penyerang:**

**B1.3 — Dampak terburuk:**

**Penjelasan PoC (langkah demi langkah):**

**Output `forge test`:**

```text
```

---

## Part C — Upgrade ke V2

**C1 — Hasil `test_UpgradePreservesState` di kontrak asli, dan apakah sesuai harapan:**

**C2.1 — Nilai yang terbaca setelah upgrade dan asal-usulnya:**

| Getter V2 | Nilai terbaca | Berasal dari slot berapa / data apa |
|---|---|---|
| `owner()` |  |  |
| `withdrawalFeeBps()` |  |  |
| `totalStaked()` |  |  |
| `stakes(alice)` |  |  |

**C2.2 — Kenapa `stakes(alice)` berubah padahal datanya tidak dihapus:**

**C2.3 — Bisakah diperbaiki setelah upgrade? Oleh siapa?**

**Penjelasan PoC:**

---

## Part D — Mitigasi & Sentralisasi

**D1 — Dua cara memperbaiki temuan inisialisasi, dan kenapa harus satu transaksi dengan deploy:**

**D2 — Teknik lain mencegah storage collision:**

**D3 — Risiko sentralisasi (severity + mitigasi):**

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
