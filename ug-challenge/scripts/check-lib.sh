#!/usr/bin/env bash
# Mesin cek mandiri yang dipakai oleh setiap ug-challenge-*/check.sh.
# Jangan dijalankan langsung. Jalankan ./check.sh dari folder challenge.
#
# Cara kerja: test di folder test/ dijalankan terhadap beberapa versi kontrak
# (asli, sudah diperbaiki, sengaja dirusak). Versi-versi itu disimpan dalam
# base64 di file .check-data supaya tidak membocorkan jawaban.

set -u
WORK=test
PASSED=0
FAILED=0

ok()      { echo "   ✅ $1"; PASSED=$((PASSED + 1)); }
bad()     { echo "   ❌ $1"; FAILED=$((FAILED + 1)); }
section() { echo; echo "── $1"; }

# has_fn <regex>: ada fungsi yang cocok di folder test/
has_fn() { grep -rqE "function $1" "$WORK" --include='*.sol'; }

# require_fn <regex> <nama>: has_fn, kalau tidak ada catat sebagai gagal
require_fn() {
    has_fn "$1" && return 0
    bad "Fungsi $2 tidak ditemukan di $WORK/"
    return 1
}

# Tulis file-file milik sebuah versi ke folder tujuan.
overlay() {
    grep "^$1 " .check-data | while read -r _ path data; do
        mkdir -p "$(dirname "$2/$path")"
        echo "$data" | base64 --decode > "$2/$path"
    done
}

# prepare <versi>: salin proyek ke folder sementara memakai versi kontrak tsb, lalu compile.
prepare() {
    local dir="$TMP/$1"
    [ -d "$dir" ] && return 0
    mkdir -p "$dir"
    cp foundry.toml "$dir/"
    cp -R src "$dir/src"
    cp -R "$WORK" "$dir/$WORK"
    ln -s "$PWD/lib" "$dir/lib"
    overlay original "$dir"   # kembalikan src asli kalau sempat diubah
    [ "$1" = original ] || overlay "$1" "$dir"
    if ! (cd "$dir" && forge build >/dev/null 2>&1); then
        if [ "$1" = original ]; then
            echo "❌ Kode di $WORK/ gagal dikompilasi. Jalankan 'forge build' untuk melihat error-nya."
        else
            echo "❌ Kode di $WORK/ gagal dikompilasi terhadap versi kontrak pembanding."
            echo "   Pastikan test hanya memakai fungsi publik yang ada di src/."
        fi
        exit 1
    fi
}

# passing <versi> <regex>: daftar nama test yang LULUS
passing() {
    prepare "$1"
    (cd "$TMP/$1" && forge test --match-test "$2" 2>&1) |
        sed -nE 's/^\[PASS\] ([A-Za-z0-9_]+)\(.*/\1/p' | sort -u
}

# expect <versi> <regex> pass|fail <pesan>
#   pass = semua test yang cocok lulus (dan minimal satu yang jalan)
#   fail = ada test yang cocok gagal
expect() {
    prepare "$1"
    local out result=fail
    # forge keluar dengan status 0 kalau tidak ada test yang cocok, jadi pastikan ada yang jalan
    if out=$(cd "$TMP/$1" && forge test --match-test "$2" 2>&1) && echo "$out" | grep -q '^\[PASS\]'; then
        result=pass
    fi
    if [ "$result" = "$3" ]; then ok "$4"; else bad "$4"; fi
}

# catches <versi> <regex> <pesan>
#   Lulus kalau ada test (cocok regex) yang lulus di kontrak asli tetapi gagal di versi ini.
#   Dipakai untuk PoC: PoC yang benar membuktikan bug ada, dan gagal ketika bug itu diperbaiki.
catches() {
    local orig var
    orig=$(passing original "$2")
    var=$(passing "$1" "$2")
    if [ -n "$(comm -23 <(echo "$orig") <(echo "$var"))" ]; then ok "$3"; else bad "$3"; fi
}

summary() {
    echo
    echo "Hasil: $PASSED lulus, $FAILED gagal."
    echo "Catatan: check.sh hanya mengecek KODE. Pastikan kamu juga bisa menjelaskan setiap baris (ANSWERS.md)."
    [ "$FAILED" -eq 0 ]
}

# run_checks "$@": dipanggil di akhir check.sh. Butuh variabel PARTS dan fungsi check_<PART>.
run_checks() {
    local part
    part=$(echo "${1:-all}" | tr '[:lower:]' '[:upper:]')
    [ -d "$WORK" ] || { echo "❌ Folder $WORK/ tidak ditemukan. Jalankan: git checkout -- $WORK"; exit 1; }
    command -v forge >/dev/null || { echo "❌ forge tidak ditemukan. Install Foundry dulu."; exit 1; }
    [ -f lib/forge-std/src/Test.sol ] || { echo "❌ forge-std belum ada. Jalankan: git submodule update --init --recursive --depth 1"; exit 1; }
    [ -f .check-data ] || { echo "❌ File .check-data hilang. Jalankan: git checkout -- .check-data"; exit 1; }

    case " $PARTS " in
        *" $part "*) ;;
        *) if [ "$part" != ALL ] && echo "$part" | grep -qE '^[A-Z]$'; then
               echo "ℹ️  Part $part tidak punya cek otomatis. Tulis jawabanmu di ANSWERS.md / FINDINGS.md."
               echo "   Part yang dicek otomatis: $PARTS"
               exit 0
           fi ;;
    esac

    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT

    echo "Mengecek $WORK/ (part: $part) ... sabar, setiap versi kontrak di-compile terpisah."
    if [ "$part" = ALL ]; then
        for p in $PARTS; do "check_$p"; done
    else
        case " $PARTS " in
            *" $part "*) "check_$part" ;;
            *) echo "Part tidak dikenal: $part (pilih salah satu: $PARTS, atau all)"; exit 1 ;;
        esac
    fi
    summary
}
