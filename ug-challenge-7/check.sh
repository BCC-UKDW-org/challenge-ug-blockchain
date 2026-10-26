#!/usr/bin/env bash
# Cek mandiri Challenge 07 — Upgrade Trap
# Pemakaian: ./check.sh [B|C|all]
cd "$(dirname "$0")" && source ../scripts/check-lib.sh

PARTS="B C"

check_B() {
    section "Part B: test_PoC_* (temuan #1)"
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
    catches fix_init '^test_PoC_' "Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

check_C() {
    section "Part C: test_UpgradePreservesState"
    if require_fn 'test_UpgradePreservesState\(' test_UpgradePreservesState; then
        expect original '^test_UpgradePreservesState\(' fail "Test upgrade menemukan masalah di kontrak asli"
        expect fix_collision '^test_UpgradePreservesState\(' pass "Test upgrade lulus di versi yang sudah benar (tidak ada false positive)"
    fi
    section "Part C: test_PoC_* (temuan #2)"
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
    catches fix_collision '^test_PoC_' "Temuan #2 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

run_checks "$@"
