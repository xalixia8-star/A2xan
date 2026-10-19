#!/usr/bin/env bash
# Menyiapkan project Flutter Vaulte:
#   1. membuat folder android/ & ios/ (flutter create) bila belum ada
#   2. menerapkan konfigurasi keamanan/platform (tools/patch_platforms.py)
#   3. mengunduh font (OFL) dan ikon brand (simple-icons, CC0)
# Jalankan dari root project:  bash tools/bootstrap.sh
set -euo pipefail
cd "$(dirname "$0")/.."

SIMPLE_ICONS_VERSION="11.14.0"
GF="https://raw.githubusercontent.com/google/fonts/main/ofl"

echo "==> Platform folders"
if [ ! -d android ] || [ ! -d ios ]; then
  flutter create --project-name vaulte --org com.vaulte \
    --platforms=android,ios --no-pub .
fi
python3 tools/patch_platforms.py
# Tes contoh bawaan flutter create merujuk MyApp yang tidak ada di project ini.
rm -f test/widget_test.dart

echo "==> Fonts"
mkdir -p assets/fonts
dl() { # url output
  [ -s "$2" ] && return 0
  curl -fsSL --retry 3 --retry-delay 2 -o "$2" "$1"
}
dl "$GF/cormorantgaramond/CormorantGaramond%5Bwght%5D.ttf" "assets/fonts/CormorantGaramond[wght].ttf"
dl "$GF/cormorantgaramond/CormorantGaramond-Italic%5Bwght%5D.ttf" "assets/fonts/CormorantGaramond-Italic[wght].ttf"
dl "$GF/inter/Inter%5Bopsz%2Cwght%5D.ttf" "assets/fonts/Inter[opsz,wght].ttf"

echo "==> Brand icons (simple-icons@$SIMPLE_ICONS_VERSION)"
mkdir -p assets/icons
slugs=$(grep -oE "slug: '[a-z0-9]+'" lib/data/catalog/service_catalog.dart | sed -E "s/slug: '(.*)'/\1/" | sort -u)
ok=0; miss=0
for s in $slugs; do
  if [ -s "assets/icons/$s.svg" ]; then ok=$((ok+1)); continue; fi
  if curl -fsSL --retry 2 -o "assets/icons/$s.svg" \
      "https://cdn.jsdelivr.net/npm/simple-icons@$SIMPLE_ICONS_VERSION/icons/$s.svg"; then
    ok=$((ok+1))
  else
    rm -f "assets/icons/$s.svg"; miss=$((miss+1))
    echo "   (tidak ada ikon: $s -> memakai inisial huruf)"
  fi
done
echo "   ikon tersedia: $ok, fallback inisial: $miss"
echo "==> Selesai. Jalankan: flutter pub get && flutter run"
