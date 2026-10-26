#!/usr/bin/env bash
# Self-check Challenge 01 — Vault Invariant Hunter
#
# Pemakaian:  ./check.sh <username-github> [A|B|C|D|all]
#
# Cara kerja: test milikmu dijalankan terhadap beberapa versi SimpleVault
# (versi asli, versi yang sudah diperbaiki, dan versi yang sengaja dirusak).
# Test yang baik harus LULUS di versi yang benar dan GAGAL di versi yang rusak.
#
# Versi-versi kontrak disimpan dalam base64 di bawah supaya tidak membocorkan
# jawaban. Men-decode-nya sebelum selesai = menyontek diri sendiri.

set -u
cd "$(dirname "$0")"

if [ $# -lt 1 ]; then
    echo "Pemakaian: ./check.sh <username-github> [A|B|C|D|all]"
    exit 1
fi

USER_DIR="submissions/$1"
PART=$(echo "${2:-all}" | tr '[:lower:]' '[:upper:]')

[ -d "$USER_DIR" ] || { echo "❌ Folder $USER_DIR tidak ditemukan. Sudah menyalin _template?"; exit 1; }
command -v forge >/dev/null || { echo "❌ forge tidak ditemukan. Install Foundry dulu."; exit 1; }
[ -f lib/forge-std/src/Test.sol ] || { echo "❌ forge-std belum ada. Jalankan: git submodule update --init --recursive"; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
PASSED=0
FAILED=0

variant_source() {
    case "$1" in
        fixed) echo 'Ly8gU1BEWC1MaWNlbnNlLUlkZW50aWZpZXI6IE1JVApwcmFnbWEgc29saWRpdHkgXjAuOC4yMDsKCmNvbnRyYWN0IFNpbXBsZVZhdWx0IHsKICAgIG1hcHBpbmcoYWRkcmVzcyA9PiB1aW50MjU2KSBwdWJsaWMgYmFsYW5jZXM7CiAgICB1aW50MjU2IHB1YmxpYyB0b3RhbERlcG9zaXRzOwoKICAgIGZ1bmN0aW9uIGRlcG9zaXQoKSBleHRlcm5hbCBwYXlhYmxlIHsKICAgICAgICByZXF1aXJlKG1zZy52YWx1ZSA+IDAsICJEZXBvc2l0IG11c3QgYmUgZ3JlYXRlciB0aGFuIHplcm8iKTsKICAgICAgICBiYWxhbmNlc1ttc2cuc2VuZGVyXSArPSBtc2cudmFsdWU7CiAgICAgICAgdG90YWxEZXBvc2l0cyArPSBtc2cudmFsdWU7CiAgICB9CgogICAgZnVuY3Rpb24gd2l0aGRyYXcodWludDI1NiBhbW91bnQpIGV4dGVybmFsIHsKICAgICAgICByZXF1aXJlKGFtb3VudCA+IDAsICJBbW91bnQgbXVzdCBiZSBncmVhdGVyIHRoYW4gemVybyIpOwogICAgICAgIHJlcXVpcmUoYmFsYW5jZXNbbXNnLnNlbmRlcl0gPj0gYW1vdW50LCAiSW5zdWZmaWNpZW50IGJhbGFuY2UiKTsKICAgICAgICBiYWxhbmNlc1ttc2cuc2VuZGVyXSAtPSBhbW91bnQ7CiAgICAgICAgdG90YWxEZXBvc2l0cyAtPSBhbW91bnQ7CiAgICAgICAgKGJvb2wgc3VjY2VzcywgKSA9IHBheWFibGUobXNnLnNlbmRlcikuY2FsbHt2YWx1ZTogYW1vdW50fSgiIik7CiAgICAgICAgcmVxdWlyZShzdWNjZXNzLCAiVHJhbnNmZXIgZmFpbGVkIik7CiAgICB9Cn0K' | base64 --decode ;;
        dep_total) echo 'Ly8gU1BEWC1MaWNlbnNlLUlkZW50aWZpZXI6IE1JVApwcmFnbWEgc29saWRpdHkgXjAuOC4yMDsKCmNvbnRyYWN0IFNpbXBsZVZhdWx0IHsKICAgIG1hcHBpbmcoYWRkcmVzcyA9PiB1aW50MjU2KSBwdWJsaWMgYmFsYW5jZXM7CiAgICB1aW50MjU2IHB1YmxpYyB0b3RhbERlcG9zaXRzOwoKICAgIGZ1bmN0aW9uIGRlcG9zaXQoKSBleHRlcm5hbCBwYXlhYmxlIHsKICAgICAgICByZXF1aXJlKG1zZy52YWx1ZSA+IDAsICJEZXBvc2l0IG11c3QgYmUgZ3JlYXRlciB0aGFuIHplcm8iKTsKICAgICAgICBiYWxhbmNlc1ttc2cuc2VuZGVyXSArPSBtc2cudmFsdWU7CiAgICB9CgogICAgZnVuY3Rpb24gd2l0aGRyYXcodWludDI1NiBhbW91bnQpIGV4dGVybmFsIHsKICAgICAgICByZXF1aXJlKGFtb3VudCA+IDAsICJBbW91bnQgbXVzdCBiZSBncmVhdGVyIHRoYW4gemVybyIpOwogICAgICAgIHJlcXVpcmUoYmFsYW5jZXNbbXNnLnNlbmRlcl0gPj0gYW1vdW50LCAiSW5zdWZmaWNpZW50IGJhbGFuY2UiKTsKICAgICAgICBiYWxhbmNlc1ttc2cuc2VuZGVyXSAtPSBhbW91bnQ7CiAgICAgICAgdG90YWxEZXBvc2l0cyAtPSBhbW91bnQ7CiAgICAgICAgKGJvb2wgc3VjY2VzcywgKSA9IHBheWFibGUobXNnLnNlbmRlcikuY2FsbHt2YWx1ZTogYW1vdW50fSgiIik7CiAgICAgICAgcmVxdWlyZShzdWNjZXNzLCAiVHJhbnNmZXIgZmFpbGVkIik7CiAgICB9Cn0K' | base64 --decode ;;
        dep_balance) echo 'Ly8gU1BEWC1MaWNlbnNlLUlkZW50aWZpZXI6IE1JVApwcmFnbWEgc29saWRpdHkgXjAuOC4yMDsKCmNvbnRyYWN0IFNpbXBsZVZhdWx0IHsKICAgIG1hcHBpbmcoYWRkcmVzcyA9PiB1aW50MjU2KSBwdWJsaWMgYmFsYW5jZXM7CiAgICB1aW50MjU2IHB1YmxpYyB0b3RhbERlcG9zaXRzOwoKICAgIGZ1bmN0aW9uIGRlcG9zaXQoKSBleHRlcm5hbCBwYXlhYmxlIHsKICAgICAgICByZXF1aXJlKG1zZy52YWx1ZSA+IDAsICJEZXBvc2l0IG11c3QgYmUgZ3JlYXRlciB0aGFuIHplcm8iKTsKICAgICAgICBiYWxhbmNlc1ttc2cuc2VuZGVyXSArPSBtc2cudmFsdWUgLyAyOwogICAgICAgIHRvdGFsRGVwb3NpdHMgKz0gbXNnLnZhbHVlOwogICAgfQoKICAgIGZ1bmN0aW9uIHdpdGhkcmF3KHVpbnQyNTYgYW1vdW50KSBleHRlcm5hbCB7CiAgICAgICAgcmVxdWlyZShhbW91bnQgPiAwLCAiQW1vdW50IG11c3QgYmUgZ3JlYXRlciB0aGFuIHplcm8iKTsKICAgICAgICByZXF1aXJlKGJhbGFuY2VzW21zZy5zZW5kZXJdID49IGFtb3VudCwgIkluc3VmZmljaWVudCBiYWxhbmNlIik7CiAgICAgICAgYmFsYW5jZXNbbXNnLnNlbmRlcl0gLT0gYW1vdW50OwogICAgICAgIHRvdGFsRGVwb3NpdHMgLT0gYW1vdW50OwogICAgICAgIChib29sIHN1Y2Nlc3MsICkgPSBwYXlhYmxlKG1zZy5zZW5kZXIpLmNhbGx7dmFsdWU6IGFtb3VudH0oIiIpOwogICAgICAgIHJlcXVpcmUoc3VjY2VzcywgIlRyYW5zZmVyIGZhaWxlZCIpOwogICAgfQp9Cg==' | base64 --decode ;;
        reentrant) echo 'Ly8gU1BEWC1MaWNlbnNlLUlkZW50aWZpZXI6IE1JVApwcmFnbWEgc29saWRpdHkgXjAuOC4yMDsKCmNvbnRyYWN0IFNpbXBsZVZhdWx0IHsKICAgIG1hcHBpbmcoYWRkcmVzcyA9PiB1aW50MjU2KSBwdWJsaWMgYmFsYW5jZXM7CiAgICB1aW50MjU2IHB1YmxpYyB0b3RhbERlcG9zaXRzOwoKICAgIGZ1bmN0aW9uIGRlcG9zaXQoKSBleHRlcm5hbCBwYXlhYmxlIHsKICAgICAgICByZXF1aXJlKG1zZy52YWx1ZSA+IDAsICJEZXBvc2l0IG11c3QgYmUgZ3JlYXRlciB0aGFuIHplcm8iKTsKICAgICAgICBiYWxhbmNlc1ttc2cuc2VuZGVyXSArPSBtc2cudmFsdWU7CiAgICAgICAgdG90YWxEZXBvc2l0cyArPSBtc2cudmFsdWU7CiAgICB9CgogICAgZnVuY3Rpb24gd2l0aGRyYXcodWludDI1NiBhbW91bnQpIGV4dGVybmFsIHsKICAgICAgICByZXF1aXJlKGFtb3VudCA+IDAsICJBbW91bnQgbXVzdCBiZSBncmVhdGVyIHRoYW4gemVybyIpOwogICAgICAgIHJlcXVpcmUoYmFsYW5jZXNbbXNnLnNlbmRlcl0gPj0gYW1vdW50LCAiSW5zdWZmaWNpZW50IGJhbGFuY2UiKTsKICAgICAgICAoYm9vbCBzdWNjZXNzLCApID0gcGF5YWJsZShtc2cuc2VuZGVyKS5jYWxse3ZhbHVlOiBhbW91bnR9KCIiKTsKICAgICAgICByZXF1aXJlKHN1Y2Nlc3MsICJUcmFuc2ZlciBmYWlsZWQiKTsKICAgICAgICB1bmNoZWNrZWQgewogICAgICAgICAgICBiYWxhbmNlc1ttc2cuc2VuZGVyXSAtPSBhbW91bnQ7CiAgICAgICAgICAgIHRvdGFsRGVwb3NpdHMgLT0gYW1vdW50OwogICAgICAgIH0KICAgIH0KfQo=' | base64 --decode ;;
        original) cat src/SimpleVault.sol ;;
    esac
}

# Siapkan salinan proyek dengan versi SimpleVault tertentu, lalu compile.
prepare() {
    local dir="$TMP/$1"
    [ -d "$dir" ] && return 0
    mkdir -p "$dir/src" "$dir/submissions"
    cp foundry.toml "$dir/"
    ln -s "$PWD/lib" "$dir/lib"
    cp -R "$USER_DIR" "$dir/submissions/"
    variant_source "$1" > "$dir/src/SimpleVault.sol"
    if ! (cd "$dir" && forge build >/dev/null 2>&1); then
        echo "❌ Kode di $USER_DIR gagal dikompilasi. Jalankan 'forge build' untuk melihat error-nya."
        exit 1
    fi
}

# expect <versi> <regex nama test> <pass|fail> <pesan jika salah>
expect() {
    prepare "$1"
    local result=fail out
    # forge keluar dengan status 0 kalau tidak ada test yang cocok, jadi pastikan ada yang benar-benar jalan
    if out=$(cd "$TMP/$1" && forge test --match-test "$2" 2>&1) && echo "$out" | grep -q '\[PASS\]'; then result=pass; fi
    if [ "$result" = "$3" ]; then
        echo "   ✅ $4"
        PASSED=$((PASSED + 1))
    else
        echo "   ❌ $4"
        FAILED=$((FAILED + 1))
    fi
}

has_fn() {
    grep -rqE "function $1" "$USER_DIR" --include='*.sol'
}

check_A() {
    echo "── Part A: testFuzz_Deposit"
    has_fn 'testFuzz_Deposit\(' || { echo "   ❌ Fungsi testFuzz_Deposit tidak ditemukan"; FAILED=$((FAILED + 1)); return; }
    expect original '^testFuzz_Deposit\(' pass "Lulus di kontrak asli (input nol & input besar sudah ditangani)"
    expect dep_total '^testFuzz_Deposit\(' fail "Mendeteksi deposit yang lupa menambah totalDeposits"
    expect dep_balance '^testFuzz_Deposit\(' fail "Mendeteksi deposit yang mencatat saldo pengguna dengan salah"
}

check_B() {
    echo "── Part B: invariant_AccountingIsConsistent"
    has_fn 'invariant_AccountingIsConsistent\(' || { echo "   ❌ Fungsi invariant_AccountingIsConsistent tidak ditemukan"; FAILED=$((FAILED + 1)); return; }
    echo "   ✅ Fungsi invariant ditemukan dan bisa dikompilasi"
    PASSED=$((PASSED + 1))
    prepare original
    if (cd "$TMP/original" && forge test --match-test '^invariant_AccountingIsConsistent\(' 2>&1 | grep -q '\[PASS\]'); then
        echo "   ℹ️  Invariant kamu LULUS di kontrak asli. Apakah kamu percaya hasilnya? (lihat pertanyaan B2)"
    else
        echo "   ℹ️  Invariant kamu GAGAL di kontrak asli. Baca call sequence-nya dengan -vvv."
    fi
}

check_C() {
    echo "── Part C: handler + invariant"
    has_fn 'invariant_AccountingIsConsistent\(' || { echo "   ❌ Fungsi invariant_AccountingIsConsistent tidak ditemukan"; FAILED=$((FAILED + 1)); return; }
    expect original '^invariant_AccountingIsConsistent\(' fail "Invariant menemukan pelanggaran di kontrak asli (kalau belum: fuzzer sudah terarah?)"
    expect fixed '^invariant_AccountingIsConsistent\(' pass "Invariant lulus di versi vault yang benar (tidak ada false positive dari handler)"
    expect dep_total '^invariant_AccountingIsConsistent\(' fail "Mendeteksi mutasi accounting #1"
    expect dep_balance '^invariant_AccountingIsConsistent\(' fail "Mendeteksi mutasi accounting #2"
}

check_D() {
    echo "── Part D1: test_PoC_*"
    if has_fn 'test_PoC_'; then
        expect original '^test_PoC_' pass "PoC lulus di kontrak asli (bug terbukti ada)"
        expect fixed '^test_PoC_' fail "PoC gagal di versi vault yang benar (PoC benar-benar menguji bug-nya)"
    else
        echo "   ❌ Tidak ada test berawalan test_PoC_"; FAILED=$((FAILED + 1))
    fi
    echo "── Part D2: test_Reentrancy*"
    if has_fn 'test_Reentrancy'; then
        expect original '^test_Reentrancy' pass "Test reentrancy lulus di kontrak asli"
        expect reentrant '^test_Reentrancy' fail "Test reentrancy gagal di vault yang memang rentan (test-mu benar-benar menguji serangan)"
    else
        echo "   ❌ Tidak ada test berawalan test_Reentrancy"; FAILED=$((FAILED + 1))
    fi
}

echo "Mengecek $USER_DIR (part: $PART) ... sabar, setiap versi di-compile terpisah."
echo
case "$PART" in
    A) check_A ;;
    B) check_B ;;
    C) check_C ;;
    D) check_D ;;
    ALL) check_A; check_B; check_C; check_D ;;
    *) echo "Part tidak dikenal: $PART (pilih A, B, C, D, atau all)"; exit 1 ;;
esac

echo
echo "Hasil: $PASSED lulus, $FAILED gagal."
echo "Catatan: check.sh hanya mengecek KODE. Penjelasan di ANSWERS.md & FINDINGS.md tetap dinilai manual."
[ "$FAILED" -eq 0 ]
