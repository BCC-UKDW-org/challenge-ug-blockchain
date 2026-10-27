#!/usr/bin/env bash
# Cek mandiri Challenge 02 — Secret Keeper
# Pemakaian: ./check.sh [B|C|all]
cd "$(dirname "$0")" && source ../scripts/check-lib.sh

PARTS="B C"

check_B() {
    section "Part B: testFuzz_NonOwnerCannotSetSecret"
    require_fn 'testFuzz_NonOwnerCannotSetSecret\(' testFuzz_NonOwnerCannotSetSecret || return
    expect original '^testFuzz_NonOwnerCannotSetSecret\(' fail "Property test menemukan pelanggaran di kontrak asli"
    expect fix_access '^testFuzz_NonOwnerCannotSetSecret\(' pass "Property test lulus di versi kontrak yang sudah benar (tidak ada false positive)"
}

check_C() {
    section "Part C: test_PoC_*"
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
    catches fix_access '^test_PoC_' "Temuan #1 terbukti (ada PoC yang gagal ketika bug ini diperbaiki)"
    if grep -rqF 'vm.load' "$WORK" --include='*.sol'; then
        ok "Temuan #2 terbukti (PoC membaca langsung dari blockchain, bukan lewat fungsi kontrak)"
    else
        bad "Temuan #2 terbukti (PoC membaca langsung dari blockchain, bukan lewat fungsi kontrak)"
    fi
}

run_checks "$@"
