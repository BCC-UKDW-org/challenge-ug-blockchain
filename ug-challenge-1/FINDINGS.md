# Findings — SimpleVault

- **Auditor:** @
- **Scope:** `src/SimpleVault.sol`
- **Metode:** Manual review, stateless fuzzing, stateful (invariant) fuzzing

## Ringkasan

| ID | Judul | Severity |
|---|---|---|
| [L-01] |  |  |

<!--
Panduan severity (sederhana):
- High          : dana bisa dicuri/terkunci, atau invariant inti rusak dengan dampak langsung.
- Medium        : dampak nyata tapi butuh kondisi tertentu, atau merusak fungsi/integrasi penting.
- Low           : dampak kecil, tidak ada kehilangan dana langsung.
- Informational : kualitas kode, best practice, tidak ada dampak keamanan.
Penomoran ID mengikuti severity: H-01, M-01, L-01, I-01.
-->

---

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

Apa yang bisa salah? Siapa yang dirugikan? Pertimbangkan pihak lain yang bergantung pada nilai ini (kontrak lain, frontend, sistem reward).

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
