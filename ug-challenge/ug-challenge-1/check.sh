#!/usr/bin/env bash
# Cek mandiri Challenge 01 — Vault Invariant Hunter
# Pemakaian: ./check.sh [A|B|C|D|all]
cd "$(dirname "$0")" && source ../scripts/check-lib.sh

PARTS="A B C D"

check_A() {
    section "Part A: testFuzz_Deposit"
    require_fn 'testFuzz_Deposit\(' testFuzz_Deposit || return
    expect original '^testFuzz_Deposit\(' pass "Lulus di kontrak asli (input nol & input besar sudah ditangani)"
    expect dep_total '^testFuzz_Deposit\(' fail "Mendeteksi deposit yang lupa menambah totalDeposits"
    expect dep_balance '^testFuzz_Deposit\(' fail "Mendeteksi deposit yang mencatat saldo pengguna dengan salah"
}

check_B() {
    section "Part B: invariant_AccountingIsConsistent"
    require_fn 'invariant_AccountingIsConsistent\(' invariant_AccountingIsConsistent || return
    ok "Fungsi invariant ditemukan dan bisa dikompilasi"
    if [ -n "$(passing original '^invariant_AccountingIsConsistent\(')" ]; then
        echo "   ℹ️  Invariant kamu LULUS di kontrak asli. Apakah kamu percaya hasilnya? (lihat pertanyaan B2)"
    else
        echo "   ℹ️  Invariant kamu GAGAL di kontrak asli. Baca call sequence-nya dengan -vvv."
    fi
}

check_C() {
    section "Part C: handler + invariant"
    require_fn 'invariant_AccountingIsConsistent\(' invariant_AccountingIsConsistent || return
    expect original '^invariant_AccountingIsConsistent\(' fail "Invariant menemukan pelanggaran di kontrak asli (kalau belum: fuzzer sudah terarah?)"
    expect fixed '^invariant_AccountingIsConsistent\(' pass "Invariant lulus di versi vault yang benar (tidak ada false positive dari handler)"
    expect dep_total '^invariant_AccountingIsConsistent\(' fail "Mendeteksi mutasi accounting #1"
    expect dep_balance '^invariant_AccountingIsConsistent\(' fail "Mendeteksi mutasi accounting #2"
}

check_D() {
    section "Part D1: test_PoC_*"
    if require_fn 'test_PoC_' 'berawalan test_PoC_'; then
        expect original '^test_PoC_' pass "PoC lulus di kontrak asli (bug terbukti ada)"
        catches fixed '^test_PoC_' "PoC gagal di versi vault yang benar (PoC benar-benar menguji bug-nya)"
    fi
    section "Part D2: test_Reentrancy*"
    if require_fn 'test_Reentrancy' 'berawalan test_Reentrancy'; then
        expect original '^test_Reentrancy' pass "Test reentrancy lulus di kontrak asli"
        catches reentrant '^test_Reentrancy' "Test reentrancy gagal di vault yang memang rentan (test-mu benar-benar menguji serangan)"
    fi
}

run_checks "$@"
