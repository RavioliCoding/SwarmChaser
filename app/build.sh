#!/bin/bash
# Builds SwarmChaser.app (a native window around dashboard/index.html) into the project folder.
# Usage: app/build.sh            — rebuild after changing anything: the app carries its own copy of
# dashboard/index.html and the sample data, so edits show up only after a rebuild.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
BUILD="$HERE/build"
APP="$ROOT/SwarmChaser.app"
mkdir -p "$BUILD"

echo "→ icon"
if [ ! -f "$BUILD/AppIcon.icns" ] || [ "$HERE/make_icon.m" -nt "$BUILD/AppIcon.icns" ]; then
  clang -O2 -fobjc-arc -framework Cocoa "$HERE/make_icon.m" -o "$BUILD/make_icon"
  "$BUILD/make_icon" "$BUILD/icon_1024.png"
  ICONSET="$BUILD/AppIcon.iconset"
  rm -rf "$ICONSET" && mkdir "$ICONSET"
  for s in 16 32 128 256 512; do
    sips -z "$s" "$s" "$BUILD/icon_1024.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
    sips -z $((s * 2)) $((s * 2)) "$BUILD/icon_1024.png" --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
  done
  iconutil -c icns "$ICONSET" -o "$BUILD/AppIcon.icns"
fi

echo "→ compile"
clang -O2 -fobjc-arc -mmacosx-version-min=13.3 -framework Cocoa -framework WebKit \
  "$HERE/main.m" -o "$BUILD/SwarmChaser"

echo "→ snapshot"
python3 -I "$HERE/embed_snapshot.py"

echo "→ bundle"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/web/dashboard"
cp "$BUILD/SwarmChaser" "$APP/Contents/MacOS/SwarmChaser"
cp "$BUILD/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
cp "$ROOT/dashboard/index.html" "$APP/Contents/Resources/web/dashboard/index.html"
# bundle the sample data so the app is self-contained (override at runtime with SWARMCHASER_ROOT)
cp -R "$ROOT/data/sample/leads" "$ROOT/data/sample/reference" "$APP/Contents/Resources/web/"
[ -d "$ROOT/data/sample/archives/app" ] && cp -R "$ROOT/data/sample/archives" "$APP/Contents/Resources/web/" || true  # optional: present only after fetch_datasets.py
cp "$HERE/Info.plist" "$APP/Contents/Info.plist"
codesign --force --sign - "$APP" >/dev/null 2>&1 || echo "  (ad-hoc codesign skipped)"
touch "$APP"  # nudge Finder/Dock to pick up the icon

echo "✓ $APP"
