#!/usr/bin/env bash
# Cek mandiri Challenge 03 — Lucky Draw I
# Pemakaian: ./check.sh [B|C|all]
cd "$(dirname "$0")" && source ../scripts/check-lib.sh

PARTS="B C"

check_poc() {
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return 1
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
}

check_B() {
    section "Part B: Temuan #1 (refund)"
    check_poc || return
    catches fix_reentrancy '^test_PoC_' "Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

check_C() {
    section "Part C: Temuan #2 (withdrawFees)"
    check_poc || return
    catches fix_eth '^test_PoC_' "Temuan #2 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

run_checks "$@"
