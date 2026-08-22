#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

VERSION="${1:-v2026.08.17-catalina-intel.1}"

QTROOT="$HOME/Qt/kits/6.4.2-macos"
OPENSSL="$ROOT/deps-catalina/prefix/openssl"
SDL="$ROOT/deps-catalina/prefix/sdl2"

BUILD="$ROOT/build-catalina-release"
STAGE="$ROOT/dist-catalina-release"
APP="$STAGE/240mp.app"

MACDEPLOYQT="$QTROOT/bin/macdeployqt"

MPV_SOURCE="/Volumes/Catalina/Applications/mpv.app.disabled/Contents/MacOS"
if [ ! -x "$MPV_SOURCE/mpv" ]; then
    MPV_SOURCE="/Volumes/Catalina/Applications/mpv.app/Contents/MacOS"
fi

if [ ! -x "$MPV_SOURCE/mpv" ]; then
    echo "ERROR: Catalina mpv 0.35 source not found."
    exit 1
fi

echo "===== CLEAN ====="
rm -rf "$BUILD" "$STAGE"

echo
echo "===== CONFIGURE ====="

CI=1 cmake -S "$ROOT" -B "$BUILD" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
  -DCMAKE_INSTALL_PREFIX="$STAGE" \
  -DAPP_VERSION="$VERSION" \
  -DQt6_DIR="$QTROOT/lib/cmake/Qt6" \
  -DCMAKE_PREFIX_PATH="$QTROOT;$OPENSSL;$SDL"

echo
echo "===== BUILD ====="

CI=1 cmake --build "$BUILD" \
  --parallel "$(sysctl -n hw.logicalcpu)"

echo
echo "===== INSTALL ====="

CI=1 cmake --install "$BUILD"

echo
echo "===== QT DEPLOY ====="
echo "This step can take a while. Do not interrupt it."

"$MACDEPLOYQT" "$APP" \
  -qmldir="$APP/Contents/Resources" \
  -libpath="$SDL/lib" \
  -libpath="$OPENSSL/lib" \
  -always-overwrite \
  -verbose=1

echo
echo "===== QT.CONF ====="

cat > "$APP/Contents/Resources/qt.conf" <<'QTEOF'
[Paths]
Plugins = PlugIns
Imports = Resources/qml
QmlImports = Resources/qml
QTEOF

echo
echo "===== EMBED MPV 0.35 ====="

rm -f "$APP/Contents/MacOS/mpv"
rm -rf "$APP/Contents/MacOS/lib"

ditto "$MPV_SOURCE/mpv" "$APP/Contents/MacOS/mpv"
ditto "$MPV_SOURCE/lib" "$APP/Contents/MacOS/lib"

chmod +x "$APP/Contents/MacOS/mpv"

echo
echo "===== VALIDATE REQUIRED FILES ====="

required=(
  "$APP/Contents/MacOS/240mp"
  "$APP/Contents/MacOS/mpv"
  "$APP/Contents/Frameworks/libSDL2-2.0.0.dylib"
  "$APP/Contents/Frameworks/QtCore.framework/Versions/A/QtCore"
  "$APP/Contents/Frameworks/QtQuick.framework/Versions/A/QtQuick"
  "$APP/Contents/PlugIns/platforms/libqcocoa.dylib"
  "$APP/Contents/Resources/qt.conf"
  "$APP/Contents/Resources/Main.qml"
)

for f in "${required[@]}"; do
    if [ ! -e "$f" ]; then
        echo "ERROR: missing required file:"
        echo "$f"
        exit 1
    fi
done

echo "Required runtime files: OK"

echo
echo "===== CHECK BACKUP FILES ====="

BACKUPS="$(find "$APP/Contents/Resources" -name '*.before-*' -print)"

if [ -n "$BACKUPS" ]; then
    echo "ERROR: backup files entered release:"
    echo "$BACKUPS"
    exit 1
fi

echo "No *.before-* files: OK"

echo
echo "===== CHECK ABSOLUTE DEVELOPMENT PATHS ====="

BAD="$(
find "$APP/Contents" -type f -perm +111 -print0 2>/dev/null |
while IFS= read -r -d '' f; do
    otool -L "$f" 2>/dev/null |
    tail -n +2 |
    grep '/Users/algarcia' || true
done
)"

if [ -n "$BAD" ]; then
    echo "ERROR: development paths remain:"
    echo "$BAD"
    exit 1
fi

echo "Absolute development dependencies: none"

echo
echo "===== TARGETS ====="

echo "240-MP:"
file "$APP/Contents/MacOS/240mp"
otool -l "$APP/Contents/MacOS/240mp" |
grep -A5 LC_BUILD_VERSION | head -6

echo
echo "mpv:"
"$APP/Contents/MacOS/mpv" --version | head -3
otool -l "$APP/Contents/MacOS/mpv" |
grep -A5 LC_BUILD_VERSION | head -6

echo
echo "===== VERSION ====="
strings "$APP/Contents/MacOS/240mp" |
grep -F "$VERSION" | head -1 || true

echo
echo "===== SIZE ====="
du -sh "$APP"

echo
echo "========================================"
echo "CATALINA RELEASE APP READY"
echo "$APP"
echo "========================================"
