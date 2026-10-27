# Findings — LuckyDrawV2

- **Auditor:** @
- **Scope:** `src/LuckyDrawV2.sol`
- **Metode:** Manual review, static analysis (compiler/linter, Slither, Aderyn), PoC dengan Foundry

## Ringkasan

| ID | Judul | Severity |
|---|---|---|
|  |  |  |
|  |  |  |
|  |  |  |

<!--
Panduan severity (sederhana):
- High          : dana bisa dicuri/terkunci, atau invariant inti rusak dengan dampak langsung.
- Medium        : dampak nyata tapi butuh kondisi tertentu, atau merusak fungsi/integrasi penting.
- Low           : dampak kecil, tidak ada kehilangan dana langsung.
- Informational : kualitas kode, best practice, tidak ada dampak keamanan.
- Gas           : optimasi biaya gas.
Penomoran ID mengikuti severity: H-01, M-01, L-01, I-01, G-01.
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

Apa yang bisa salah? Siapa yang dirugikan? Berapa besar kerugiannya?

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

---

<!-- Salin blok [X-01] di atas untuk temuan berikutnya. -->
