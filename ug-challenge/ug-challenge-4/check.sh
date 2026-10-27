#!/usr/bin/env bash
# Cek mandiri Challenge 04 — Lucky Draw II
# Pemakaian: ./check.sh [B|C|D|all]
cd "$(dirname "$0")" && source ../scripts/check-lib.sh

PARTS="B C D"

check_poc() {
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return 1
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
}

check_B() {
    section "Part B: biaya gas enter()"
    check_poc || return
    catches fix_dos '^test_PoC_' "Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

check_C() {
    section "Part C: keacakan drawWinner()"
    check_poc || return
    catches fix_rng '^test_PoC_' "Temuan #2 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

check_D() {
    section "Part D: pembukuan fee"
    check_poc || return
    catches fix_cast '^test_PoC_' "Temuan #3 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
}

run_checks "$@"
