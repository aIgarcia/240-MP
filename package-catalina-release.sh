#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

VERSION="${1:-v2026.08.17-intel-macos}"
BUNDLE_VERSION="$(printf '%s\n' "$VERSION" | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*$/\1/')"

if [ "$BUNDLE_VERSION" = "$VERSION" ]; then
    echo "ERROR: unable to derive numeric bundle version from:"
    echo "$VERSION"
    exit 1
fi

QTROOT="$HOME/Qt/kits/6.4.2-macos"
OPENSSL="$ROOT/deps-catalina/prefix/openssl"
SDL="$ROOT/deps-catalina/prefix/sdl2"

BUILD="$ROOT/build-catalina-release"
STAGE="$ROOT/dist-catalina-release"
APP="$STAGE/240mp.app"

MACDEPLOYQT="$QTROOT/bin/macdeployqt"

MPV_VERSION="0.35.0"
MPV_URL="https://laboratory.stolendata.net/~djinn/mpv_osx/mpv-0.35.0.tar.gz"
MPV_SHA256="376415c787aef391a3927cdecd5bb0dac9f21ef9d7742516b8cd8d8ce502e7b6"

MPV_CACHE="$HOME/Library/Caches/240-MP/catalina-mpv"
MPV_ARCHIVE="$MPV_CACHE/mpv-$MPV_VERSION.tar.gz"
MPV_EXTRACT="$MPV_CACHE/mpv-$MPV_VERSION"

prepare_mpv() {
    mkdir -p "$MPV_CACHE"

    if [ -f "$MPV_ARCHIVE" ]; then
        ACTUAL="$(shasum -a 256 "$MPV_ARCHIVE" | awk '{print $1}')"

        if [ "$ACTUAL" != "$MPV_SHA256" ]; then
            echo "Cached mpv archive has wrong checksum; removing it."
            rm -f "$MPV_ARCHIVE"
        fi
    fi

    if [ ! -f "$MPV_ARCHIVE" ]; then
        echo "Downloading mpv $MPV_VERSION from Stolendata..."
        rm -f "$MPV_ARCHIVE.tmp"

        curl -fL           --retry 3           --connect-timeout 20           "$MPV_URL"           -o "$MPV_ARCHIVE.tmp"

        mv "$MPV_ARCHIVE.tmp" "$MPV_ARCHIVE"
    fi

    ACTUAL="$(shasum -a 256 "$MPV_ARCHIVE" | awk '{print $1}')"

    if [ "$ACTUAL" != "$MPV_SHA256" ]; then
        echo "ERROR: mpv archive checksum mismatch."
        echo "Expected: $MPV_SHA256"
        echo "Actual:   $ACTUAL"
        exit 1
    fi

    echo "mpv archive SHA-256: OK"

    rm -rf "$MPV_EXTRACT"
    mkdir -p "$MPV_EXTRACT"

    tar -xzf "$MPV_ARCHIVE" -C "$MPV_EXTRACT"

    MPV_APP="$(find "$MPV_EXTRACT" -type d -name 'mpv.app' -print -quit)"

    if [ -z "$MPV_APP" ]; then
        echo "ERROR: mpv.app not found inside archive."
        exit 1
    fi

    MPV_SOURCE="$MPV_APP/Contents/MacOS"

    if [ ! -x "$MPV_SOURCE/mpv" ] || [ ! -d "$MPV_SOURCE/lib" ]; then
        echo "ERROR: incomplete mpv runtime in archive."
        exit 1
    fi

    echo "mpv runtime source:"
    echo "$MPV_APP"
}

echo
echo "===== MPV 0.35 SOURCE ====="
prepare_mpv

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
echo "===== BUNDLE VERSION ====="

/usr/bin/plutil -replace CFBundleShortVersionString -string "$BUNDLE_VERSION" "$APP/Contents/Info.plist"
/usr/bin/plutil -replace CFBundleVersion -string "$BUNDLE_VERSION" "$APP/Contents/Info.plist"

/usr/bin/plutil -p "$APP/Contents/Info.plist" |
grep -E 'CFBundleShortVersionString|CFBundleVersion'

echo
echo "===== EMBED MPV 0.35 ====="

rm -f "$APP/Contents/MacOS/mpv"
rm -rf "$APP/Contents/MacOS/lib"

ditto "$MPV_SOURCE/mpv" "$APP/Contents/MacOS/mpv"
ditto "$MPV_SOURCE/lib" "$APP/Contents/MacOS/lib"

chmod +x "$APP/Contents/MacOS/mpv"

echo
echo "===== THIRD-PARTY NOTICES ====="

mkdir -p "$APP/Contents/Resources/licenses/mpv-0.35.0"

ditto   "$ROOT/third_party/mpv-0.35.0"   "$APP/Contents/Resources/licenses/mpv-0.35.0"

cp   "$ROOT/THIRD_PARTY_NOTICES.md"   "$APP/Contents/Resources/THIRD_PARTY_NOTICES.md"

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
  "$APP/Contents/Resources/THIRD_PARTY_NOTICES.md"
  "$APP/Contents/Resources/licenses/mpv-0.35.0/SOURCE.txt"
  "$APP/Contents/Resources/licenses/mpv-0.35.0/Copyright"
  "$APP/Contents/Resources/licenses/mpv-0.35.0/LICENSE.GPL"
  "$APP/Contents/Resources/licenses/mpv-0.35.0/LICENSE.LGPL"
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
