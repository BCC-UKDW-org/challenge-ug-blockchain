# Jawaban — Challenge 02: Secret Keeper

- **Nama:** 
- **GitHub:** @

> Tulis dengan kata-katamu sendiri. Jawaban yang tidak bisa kamu jelaskan saat tanya jawab dianggap tidak valid.

---

## Part A — Recon & Scoping

**A1 — Peta kontrak:**

| Fungsi | Siapa yang **boleh** memanggil (menurut NatSpec) | Siapa yang **bisa** memanggil (menurut kode) | Mengubah state? |
|---|---|---|---|
| `constructor` |  |  |  |
| `setSecret` |  |  |  |
| `getSecret` |  |  |  |

**A2 — Storage layout (`forge inspect SecretKeeper storageLayout`):**

| Variabel | Tipe | Slot |
|---|---|---|
|  |  |  |

**A3 — Daftar klaim keamanan:**

| Klaim | Sumber (NatSpec / developer) | Status (benar / salah / belum tahu) | Bukti |
|---|---|---|---|
|  |  |  |  |

---

## Part B — Property Test

**Penjelasan test (kenapa setiap baris ada):**

**B2.1 — Lulus atau gagal? Apakah sesuai harapan?**

**B2.2 — Counterexample dari fuzzer:**

```text
(tempel di sini)
```

**B2.3 — Kenapa owner harus dikecualikan?**

---

## Part C — Proof of Code

**Penjelasan PoC temuan pertama:**

**Penjelasan PoC temuan kedua (cara decode slot):**

**C.1 — Arti `private` di Solidity:**

**C.2 — Cara membaca storage kontrak di jaringan sungguhan:**

**C.3 — Kenapa temuan kedua tidak bisa diperbaiki dengan modifier/`require`:**

**Output `forge test`:**

```text
```

---

## Part D — Severity

| Temuan | Impact | Likelihood | Severity | Alasan |
|---|---|---|---|---|
| #1 |  |  |  |  |
| #2 |  |  |  |  |

**D.2 — Judul mana yang lebih baik dan kenapa:**

---

## Hint yang Dibuka

Jujur saja, membuka hint tidak mengurangi nilai.

| Part | Hint 1 | Hint 2 | Hint 3 |
|---|---|---|---|
| B | ☐ | ☐ | ☐ |
| C | ☐ | ☐ | ☐ |
| D | ☐ | — | — |

## Referensi yang Dipakai

- 
