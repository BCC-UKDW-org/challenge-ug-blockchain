#!/usr/bin/env bash
# Cek mandiri Challenge 08 — Mini Bridge
# Pemakaian: ./check.sh [B|C|all]
cd "$(dirname "$0")" && source ../scripts/check-lib.sh

PARTS="B C"

check_B() {
    section "Part B: test_PoC_* (temuan #1)"
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
    catches fix_from '^test_PoC_' "Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

check_C() {
    section "Part C: test_PoC_* (temuan #2)"
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
    catches fix_replay '^test_PoC_' "Temuan #2 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

run_checks "$@"
