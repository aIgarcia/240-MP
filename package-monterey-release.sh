#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

RELEASE_LABEL="${1:-v2026.08.17-monterey-intel.3}"
APP_VERSION="$RELEASE_LABEL"

BUILD="$ROOT/build-monterey-release"
DIST="$ROOT/dist-monterey-release"
APP="$DIST/240mp.app"

QT_ROOT="${QT_ROOT:-$HOME/Qt/6.5.3/macos}"
QT6_DIR="$QT_ROOT/lib/cmake/Qt6"
MACDEPLOYQT="$QT_ROOT/bin/macdeployqt"


echo "============================================================"
echo "240-MP MONTEREY INTEL RELEASE BUILD"
echo "============================================================"
echo "Release:      $RELEASE_LABEL"
echo "App version:  $APP_VERSION"
echo "Architecture: x86_64"
echo "Target:       macOS 12.0"
echo "Qt:           6.5.3"
echo

for tool in cmake brew codesign xattr shasum otool file; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: required tool not found: $tool"
        exit 1
    fi
done

if [ ! -f "$QT6_DIR/Qt6Config.cmake" ]; then
    echo "ERROR: Qt 6.5.3 was not found at:"
    echo "$QT_ROOT"
    echo
    echo "Set QT_ROOT to an alternate Qt 6.5.3 installation if needed."
    exit 1
fi

if [ ! -x "$MACDEPLOYQT" ]; then
    echo "ERROR: macdeployqt was not found at:"
    echo "$MACDEPLOYQT"
    exit 1
fi

OPENSSL_PREFIX="$(brew --prefix openssl@3)"
SDL_PREFIX="$(brew --prefix sdl2-compat)"

echo "OpenSSL:      $OPENSSL_PREFIX"
echo "SDL2:         $SDL_PREFIX"
echo

echo "============================================================"
echo "CLEAN BUILD"
echo "============================================================"

rm -rf "$BUILD"
rm -rf "$DIST"

CI=1 cmake \
    -S "$ROOT" \
    -B "$BUILD" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DAPP_VERSION="$APP_VERSION" \
    -DQt6_DIR="$QT6_DIR" \
    -DCMAKE_PREFIX_PATH="$QT_ROOT;$OPENSSL_PREFIX;$SDL_PREFIX"

echo
echo "============================================================"
echo "BUILD"
echo "============================================================"

cmake --build "$BUILD" \
    --parallel "$(sysctl -n hw.logicalcpu)"

echo
echo "============================================================"
echo "INSTALL"
echo "============================================================"

CI=1 cmake --install "$BUILD" \
    --prefix "$DIST"

if [ ! -d "$APP" ]; then
    echo "ERROR: application bundle was not produced:"
    echo "$APP"
    exit 1
fi

if [ -L "$APP/Contents/Resources" ]; then
    echo "ERROR: Contents/Resources is a development symlink."
    exit 1
fi

echo
echo "============================================================"
echo "QT DEPLOYMENT"
echo "============================================================"

"$MACDEPLOYQT" \
    "$APP" \
    -qmldir="$APP/Contents/Resources" \
    -verbose=2

cat > "$APP/Contents/Resources/qt.conf" <<'QTCONF_EOF'
[Paths]
Plugins = PlugIns
Imports = Resources/qml
QmlImports = Resources/qml
QTCONF_EOF

echo
echo "============================================================"
echo "AD-HOC SIGNATURE"
echo "============================================================"

xattr -cr "$APP"

codesign \
    --force \
    --deep \
    --sign - \
    "$APP"

codesign \
    --verify \
    --deep \
    --strict \
    --verbose=2 \
    "$APP"

echo
echo "============================================================"
echo "RUNTIME VALIDATION"
echo "============================================================"

required=(
    "$APP/Contents/MacOS/240mp"
    "$APP/Contents/Frameworks/QtCore.framework/Versions/A/QtCore"
    "$APP/Contents/Frameworks/QtQuick.framework/Versions/A/QtQuick"
    "$APP/Contents/Frameworks/libSDL2-2.0.0.dylib"
    "$APP/Contents/PlugIns/platforms/libqcocoa.dylib"
    "$APP/Contents/Resources/Main.qml"
    "$APP/Contents/Resources/qt.conf"
)

for item in "${required[@]}"; do
    if [ ! -e "$item" ]; then
        echo "ERROR: required runtime file is missing:"
        echo "$item"
        exit 1
    fi
done

echo "Required runtime files: OK"

echo
echo "Checking non-system absolute dependencies..."

ABSOLUTE_DEPS="$(
    otool -L "$APP/Contents/MacOS/240mp" |
    awk '/^\t\// && $1 !~ /^\/System\// && $1 !~ /^\/usr\/lib\// {print}'
)"

if [ -n "$ABSOLUTE_DEPS" ]; then
    echo "ERROR: non-system absolute dependencies found:"
    echo "$ABSOLUTE_DEPS"
    exit 1
fi

echo "Absolute development dependencies: NONE"

echo
echo "Checking development-machine paths..."

if grep -a -q "/Users/$USER/" "$APP/Contents/MacOS/240mp"; then
    echo "ERROR: development-machine path found in executable."
    exit 1
fi

echo "Development-machine paths: NONE"

echo
echo "============================================================"
echo "BINARY TARGET"
echo "============================================================"

file "$APP/Contents/MacOS/240mp"

otool -l "$APP/Contents/MacOS/240mp" |
grep -A5 LC_BUILD_VERSION |
head -6

echo
echo "============================================================"
echo "EXECUTABLE SHA-256"
echo "============================================================"

ACTUAL_SHA256="$(
    shasum -a 256 "$APP/Contents/MacOS/240mp" |
    awk '{print $1}'
)"

echo "$ACTUAL_SHA256"
echo

echo "============================================================"
echo "VERSION"
echo "============================================================"

strings "$APP/Contents/MacOS/240mp" |
grep -E '240-MP/v|v2026\.' |
head -10 || true

echo
echo "============================================================"
echo "APPLICATION SIZE"
echo "============================================================"

du -sh "$APP"

echo
echo "============================================================"
echo "EXTERNAL PLAYBACK REQUIREMENTS"
echo "============================================================"

echo "mpv is not bundled with the Monterey release."
echo "yt-dlp is not bundled with the Monterey release."
echo "These remain external runtime dependencies."

echo
echo "============================================================"
echo "MONTEREY RELEASE APP READY"
echo "============================================================"
echo "$APP"
