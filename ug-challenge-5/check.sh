#!/usr/bin/env bash
# Cek mandiri Challenge 05 — Mini AMM
# Pemakaian: ./check.sh [A|B|C|all]
cd "$(dirname "$0")" && source ../scripts/check-lib.sh

PARTS="A B C"
FIXES="fix_fee fix_slippage fix_deadline fix_incentive"

# isolates <versi> <pesan>
#   Lulus kalau ada PoC yang: lulus di kontrak asli, gagal ketika bug ini diperbaiki,
#   dan TETAP lulus ketika bug-bug lain yang diperbaiki. Artinya PoC itu fokus pada satu bug.
isolates() {
    local target=$1 candidates other
    candidates=$(comm -23 <(passing original '^test_PoC_') <(passing "$target" '^test_PoC_'))
    for other in $FIXES; do
        [ "$other" = "$target" ] && continue
        candidates=$(comm -12 <(echo "$candidates") <(passing "$other" '^test_PoC_'))
    done
    if [ -n "$candidates" ]; then ok "$2"; else bad "$2"; fi
}

check_A() {
    section "Part A: testFuzz_GetOutputAmount (stateless fuzz)"
    require_fn 'testFuzz_GetOutputAmount\(' testFuzz_GetOutputAmount || return
    expect original '^testFuzz_GetOutputAmount\(' pass "Lulus di kontrak asli (input sudah dibatasi dengan benar)"
    expect mut_spot '^testFuzz_GetOutputAmount\(' fail "Mendeteksi rumus output yang membuat x * y turun"
}

check_B() {
    section "Part B: invariant_ConstantProduct (stateful fuzz + handler)"
    require_fn 'invariant_ConstantProduct\(' invariant_ConstantProduct || return
    expect original '^invariant_ConstantProduct\(' fail "Invariant menemukan pelanggaran di kontrak asli (kalau belum: handler sudah melakukan swap dua arah?)"
    expect fix_incentive '^invariant_ConstantProduct\(' pass "Invariant lulus setelah bug yang ditemukan fuzzer diperbaiki (tidak ada false positive)"
    expect mut_spot '^invariant_ConstantProduct\(' fail "Mendeteksi mutasi rumus swap yang membuat x * y turun"
}

check_C() {
    section "Part C: test_PoC_*"
    require_fn 'test_PoC_' 'berawalan test_PoC_' || return
    expect original '^test_PoC_' pass "Semua PoC lulus di kontrak asli (bug terbukti ada)"
    isolates fix_incentive "Temuan #1 terbukti (ada PoC yang gagal hanya ketika bug ini diperbaiki)"
    isolates fix_fee "Temuan #2 terbukti (ada PoC yang gagal hanya ketika bug ini diperbaiki)"
    isolates fix_slippage "Temuan #3 terbukti (ada PoC yang gagal hanya ketika bug ini diperbaiki)"
    isolates fix_deadline "Temuan #4 terbukti (ada PoC yang gagal hanya ketika bug ini diperbaiki)"
}

run_checks "$@"
