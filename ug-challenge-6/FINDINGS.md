# Findings — Flash Lender

- **Auditor:** @
- **Scope:** `src/FlashLender.sol`, `src/CollateralLoan.sol`
- **Metode:** Manual review, unit test, PoC dengan kontrak penyerang

## Ringkasan

| ID | Judul | Severity |
|---|---|---|
|  |  |  |
|  |  |  |

<!--
Panduan severity (sederhana):
- High          : dana bisa dicuri/terkunci, atau invariant inti rusak dengan dampak langsung.
- Medium        : dampak nyata tapi butuh kondisi tertentu, atau merusak fungsi/integrasi penting.
- Low           : dampak kecil, tidak ada kehilangan dana langsung.
- Informational : kualitas kode, best practice, tidak ada dampak keamanan.
Penomoran ID mengikuti severity: H-01, M-01, L-01, I-01.
-->

---

<!-- Salin bagian di bawah ini untuk setiap temuan (ada 2 temuan). -->

## [X-01] Judul singkat yang menjelaskan masalah DAN dampaknya

### Severity

**Impact:** High / Medium / Low
**Likelihood:** High / Medium / Low

Alasan pemilihan severity:

### Description

Jelaskan akar masalahnya. Tunjuk baris kode yang relevan.

```solidity
// potongan kode yang bermasalah
```

### Impact

Apa yang bisa salah? Siapa yang dirugikan (LP, treasury, peminjam lain)? Berapa besar kerugiannya?

### Proof of Concept

Langkah-langkah:

1. 
2. 

Test PoC (taruh juga di file test kamu):

```solidity
function test_PoC_...() public {
}
```

Output:

```text
```

### Recommended Mitigation

```diff
- baris lama
+ baris baru
```
