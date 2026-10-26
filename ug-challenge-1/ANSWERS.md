# Jawaban — Challenge 01: Vault Invariant Hunter

- **Nama:** 
- **GitHub:** @
- **Jalur belajar:** Lengkap / Cepat

> Tulis dengan kata-katamu sendiri. Jawaban yang tidak bisa kamu jelaskan saat defense dianggap tidak valid.

---

## Tabel Fungsi

| Fungsi | `balances[msg.sender]` | `totalDeposits` | ETH di kontrak | External call? |
|---|---|---|---|---|
| `deposit()` |  |  |  |  |
| `withdraw(amount)` |  |  |  |  |

---

## Part A — Stateless Fuzzing

**Alasan memilih assertion:**

**Cara menangani input nol & input besar (dan kenapa memilih cara itu):**

**A2.1 — Apakah semua input menghasilkan hasil yang benar?**

**A2.2 — Output saat penanganan input dihapus:**

```text
(tempel output forge test di sini)
```

**A2.3 — Revert yang diharapkan vs bug:**

**A2.4 — Kenapa `uint96`? Nilai maksimumnya dalam ether?**

**Output akhir `forge test`:**

```text
```

---

## Part B — Invariant

**B1 — Invariant 1 (persamaan):**

```text
```

**B1 — Invariant 2 (melibatkan `address(vault).balance`):**

```text
```

**Apakah invariant tersebut bertahan untuk setiap fungsi? Telusuri:**

**Eksperimen `is Test, StdInvariant` — error apa dan kenapa?**

**B2.1 — Apakah test naif lulus? Apakah kamu percaya?**

**B2.2 — Siapa `msg.sender` yang dipakai fuzzer?**

**B2.3 — Analisis jumlah revert (`-vvvv`):**

---

## Part C — Handler

**Penjelasan desain handler (pemilihan aktor, `bound`, early return):**

**C2.1 — Perbedaan hasil dengan Part B:**

**C2.2 — Call sequence yang melanggar invariant:**

```text
(tempel di sini)
```

**Penjelasan langkah demi langkah:**

| Langkah | Aksi | `balances[alice]` | `balances[bob]` | `totalDeposits` |
|---|---|---|---|---|
| 1 |  |  |  |  |

**C2.3 — Bug di test atau di kontrak? Buktinya:**

**C2.4 — Invariant mana yang dilanggar, mana yang bertahan, dan apa artinya?**

**Bonus — ghost variables:**

---

## Part D — Security Researcher Mode

**D1 — Accounting:** lihat `FINDINGS.md`.

**D2 — Reentrancy (analisis urutan eksekusi + hasil test `Attacker`):**

**D3 — Minimal dua alasan invariant yang lulus ≠ kontrak aman:**

1. 
2. 

---

## Hint yang Dibuka

Jujur saja, membuka hint tidak mengurangi nilai.

| Part | Hint 1 | Hint 2 | Hint 3 |
|---|---|---|---|
| A | ☐ | ☐ | ☐ |
| B | ☐ | ☐ | — |
| C | ☐ | ☐ | ☐ |
| D | ☐ | ☐ | ☐ |

## Referensi yang Dipakai

- 
