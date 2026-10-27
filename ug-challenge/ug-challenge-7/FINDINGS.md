# Findings — StakingVault (Proxy, V1, V2)

- **Auditor:** @
- **Scope:** `src/VaultProxy.sol`, `src/StakingVaultV1.sol`, `src/StakingVaultV2.sol`
- **Metode:** Manual review, perbandingan storage layout, Proof of Code

## Ringkasan

| ID | Judul | Severity |
|---|---|---|
|  |  |  |
|  |  |  |

<!--
Panduan severity (sederhana):
- High          : dana bisa dicuri/terkunci, atau fungsi inti protokol rusak dengan dampak langsung.
- Medium        : dampak nyata tapi butuh kondisi tertentu, atau merusak fungsi/integrasi penting.
- Low           : dampak kecil, tidak ada kehilangan dana langsung.
- Informational : kualitas kode, best practice, tidak ada dampak keamanan.
Penomoran ID mengikuti severity: H-01, M-01, L-01, I-01.
Temuan sentralisasi (Part D3) boleh ditambahkan sebagai temuan ketiga.
-->

---

## [X-01] Judul singkat yang menjelaskan akar masalah DAN dampaknya

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

Apa yang bisa salah? Siapa yang dirugikan?

### Proof of Concept

Langkah-langkah:

1. 
2. 

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

## [X-02] Judul singkat yang menjelaskan akar masalah DAN dampaknya

### Severity

**Impact:** High / Medium / Low
**Likelihood:** High / Medium / Low

Alasan pemilihan severity:

### Description

### Impact

### Proof of Concept

```solidity
function test_PoC_...() public {
}
```

### Recommended Mitigation

```diff
```
