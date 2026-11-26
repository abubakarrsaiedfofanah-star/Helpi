#!/usr/bin/env bash
set -euo pipefail

: "${API_URL:?Set API_URL in the Vercel project environment to the deployed Helpi API URL ending in /api}"

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.2}"
SDK_ROOT="${TMPDIR:-/tmp}/helpi-flutter-sdk"
FLUTTER_ROOT="$SDK_ROOT/flutter"
ARCHIVE="$SDK_ROOT/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [[ ! -x "$FLUTTER_ROOT/bin/flutter" ]]; then
  mkdir -p "$SDK_ROOT"
  curl --fail --location --retry 3 --retry-delay 2 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    --output "$ARCHIVE"
  tar -xf "$ARCHIVE" -C "$SDK_ROOT"
  rm -f "$ARCHIVE"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"
flutter config --no-analytics
flutter pub get
BASE_HREF="${BASE_HREF:-/}"
flutter build web --release --base-href "$BASE_HREF" \
  --dart-define="API_URL=${API_URL}" \
  --dart-define="ADMIN_PORTAL_URL=${ADMIN_PORTAL_URL:-}"
