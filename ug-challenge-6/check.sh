#!/usr/bin/env bash
# Cek mandiri Challenge 06 — Flash Lender
# Pemakaian: ./check.sh [A|B|C|all]
cd "$(dirname "$0")" && source ../scripts/check-lib.sh

PARTS="A B C"

check_A() {
    section "Part A: test_HonestFlashLoanPaysFee"
    require_fn 'test_HonestFlashLoanPaysFee\(' test_HonestFlashLoanPaysFee || return
    expect original '^test_HonestFlashLoanPaysFee\(' pass "Flash loan yang jujur berhasil di kontrak asli"
    expect mut_fee '^test_HonestFlashLoanPaysFee\(' fail "Mendeteksi fee flash loan yang tidak menjadi milik LP"
}

check_B() {
    section "Part B: PoC FlashLender (test_PoC_*)"
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
    catches fix_repay '^test_PoC_' "Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

check_C() {
    section "Part C: PoC CollateralLoan (test_PoC_*)"
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
    catches fix_oracle '^test_PoC_' "Temuan #2 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

run_checks "$@"
