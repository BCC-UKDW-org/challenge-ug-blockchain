#!/usr/bin/env bash
# KHUSUS MAINTAINER: kelola versi-versi kontrak pembanding untuk check.sh.
#
#   scripts/variants.sh pack   <folder-challenge> <folder-varian>
#   scripts/variants.sh unpack <folder-challenge> <folder-tujuan>
#
# Struktur folder varian:
#   <folder-varian>/original/src/...        salinan src asli (wajib)
#   <folder-varian>/<nama-varian>/src/...   hanya file yang berbeda dari asli
#
# Jangan commit folder varian ke repo publik: isinya membocorkan jawaban.

set -eu
cmd=$1
challenge=$(cd "$2" && pwd)
dir=$3

case "$cmd" in
    pack)
        dir=$(cd "$dir" && pwd)
        [ -d "$dir/original" ] || { echo "Folder $dir/original wajib ada"; exit 1; }
        out="$challenge/.check-data"
        : > "$out"
        for v in $(cd "$dir" && ls -d */ | tr -d /); do
            (cd "$dir/$v" && find . -type f -name '*.sol' | sed 's#^\./##' | sort) | while read -r f; do
                printf '%s %s %s\n' "$v" "$f" "$(base64 < "$dir/$v/$f" | tr -d '\n')" >> "$out"
            done
        done
        echo "Ditulis: $out ($(wc -l < "$out" | tr -d ' ') file)"
        ;;
    unpack)
        mkdir -p "$dir"
        while read -r v path data; do
            mkdir -p "$(dirname "$dir/$v/$path")"
            echo "$data" | base64 --decode > "$dir/$v/$path"
        done < "$challenge/.check-data"
        echo "Diekstrak ke: $dir"
        ;;
    *) echo "Perintah tidak dikenal: $cmd (pack|unpack)"; exit 1 ;;
esac
