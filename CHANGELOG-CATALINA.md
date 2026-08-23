# 240-MP — Catalina Intel

This document describes the macOS Catalina Intel build maintained in this fork.

The Catalina port is based on upstream 240-MP v2026.08.17 and targets Intel Macs running macOS 10.15.

## Release

### v2026.08.17-catalina-intel.1

Base upstream release:

- 240-MP v2026.08.17
- Upstream commit: `b434603`

Target:

- macOS Catalina 10.15
- Intel x86_64
- Application deployment target: macOS 10.15
- Built on macOS Monterey
- Qt 6.4.2

The final release application was tested on macOS Catalina 10.15.7 on Intel hardware.

## Catalina compatibility work

The upstream application requires adjustments to build and run correctly on Catalina with the older Qt and mpv versions used by this port.

### Qt 6.4.2

The Catalina build uses Qt 6.4.2 instead of the newer Qt version used by the Monterey build.

Compatibility adjustments were made to QML effects and related UI code in:

- `modules/nfc_reader/views/Items.qml`
- `modules/weather/views/screens/CurrentConditions.qml`
- `modules/weather/views/screens/ExtendedForecast.qml`
- `views/Components/AppBar.qml`

These changes are compatibility adaptations for Qt 6.4 and do not imply that every affected module has been functionally validated on Catalina.

## mpv 0.35.0

Catalina uses mpv 0.35.0.

The release packaging script downloads the macOS build published by Stolendata and verifies the archive before using it.

Archive:

`mpv-0.35.0.tar.gz`

SHA-256:

`376415c787aef391a3927cdecd5bb0dac9f21ef9d7742516b8cd8d8ce502e7b6`

The embedded mpv executable used by the tested Catalina release has SHA-256:

`b22994f6cabc81144fbc54f60e7959078bd5df8dbc27661ae046cbcc97a2a6a2`

The release packaging process embeds the mpv executable together with the runtime libraries shipped in that macOS build.

Third-party source and licensing information is preserved in:

- `THIRD_PARTY_NOTICES.md`
- `third_party/mpv-0.35.0/`

The bundled mpv files are not modified by this fork.

## mpv 0.35 compatibility

Several adjustments were required because mpv 0.35 predates behavior expected by current upstream 240-MP.

### Font handling

The VCR OSD Mono font is already included in 240-MP assets.

For Catalina, 240-MP installs the bundled font into the current user's `~/Library/Fonts` directory when necessary and explicitly selects `VCR OSD Mono` for mpv OSD and subtitles.

This avoids relying on newer mpv font-directory behavior unavailable in mpv 0.35.

### Subtitle handling

The current upstream forced-subtitle behavior is not fully available in mpv 0.35.

When no subtitle track is selected, the Catalina build uses:

`--sid=no`

### mpv discovery

The Catalina build can locate mpv in the following order:

1. An mpv executable bundled beside the 240-MP executable
2. `PATH`
3. `/usr/local/bin/mpv`
4. `/opt/homebrew/bin/mpv`
5. `/Applications/mpv.app/Contents/MacOS/mpv`
6. `~/Applications/mpv.app/Contents/MacOS/mpv`

Release builds embed mpv directly inside the application bundle, so an external mpv installation is not required.

## Playback OSD

The Intel macOS builds include an expanded playback OSD compared with upstream.

The OSD can display additional playback metadata such as:

- display title
- video information
- normalized frame rate
- audio information
- subtitle information
- track position

The Catalina implementation uses the same custom `scripts/mpv-osc.lua` work as the Monterey Intel build.

## Fullscreen

A macOS-specific fullscreen issue that could produce a white border around playback was corrected by allowing native macOS fullscreen behavior instead of forcing the previous non-native fullscreen option.

## SDL2

SDL2 is included automatically in the macOS application bundle during installation.

The release build therefore does not depend on a separately installed SDL2 runtime.

## Release packaging

`package-catalina-release.sh` performs the complete Catalina release build.

The script:

- configures an x86_64 macOS 10.15 build
- uses Qt 6.4.2
- builds in Release mode
- installs a self-contained application resource tree
- runs `macdeployqt`
- installs `qt.conf`
- downloads and verifies mpv 0.35.0
- embeds mpv and its runtime libraries
- includes third-party notices and mpv licensing information
- checks required runtime files
- rejects leftover `*.before-*` development backup files
- checks for absolute development-machine library dependencies
- reports binary deployment targets, version and final application size

Release packaging must use `CI=1` so that application resources are copied into the bundle rather than represented by development symlinks.

## Validation

The Catalina application was tested on:

- macOS Catalina 10.15.7
- Intel x86_64

The final tested application executable has SHA-256:

`ac28fb811b1c84ccb1b8a6a21bb458a94af244e945943798c3c4dc55f6a9dcd6`

The reproducibly packaged application generated after introducing automatic mpv download produced the same 240-MP executable and the same mpv executable as the build tested directly on Catalina.

### Tested functionality

The following functionality has been exercised successfully on Catalina:

- application startup and navigation
- Plex
- Jellyfin
- Local Files
- Ambient Mode
- Weather
- media playback
- embedded mpv
- playback OSD
- VCR OSD Mono font
- fullscreen
- application icon

Plex and Ambient Mode were also exercised during the final standalone-runtime test with the external Catalina mpv installation disabled, confirming that playback was using the mpv runtime embedded inside 240-MP.

## Not validated

### YouTube / yt-dlp

yt-dlp is not bundled with this Catalina release.

YouTube functionality has not been validated as part of this release and remains future work.

### NFC

NFC functionality has not been tested on Catalina and should not be considered validated by this port.

## macOS Mojave

Some components used by this port, including Qt 6.4.2 and the selected mpv 0.35 build, have deployment targets compatible with macOS 10.14.

The 240-MP executable itself is currently built with a macOS 10.15 deployment target.

Mojave has not been tested and is not a supported target of this release.

## Known non-blocking build warnings

`macdeployqt` may report warnings related to optional Qt SQL plugins such as ODBC or PostgreSQL and may initially report that the SDL2 rpath cannot be resolved during dependency scanning.

SDL2 is explicitly installed into the application Frameworks directory and the completed bundle has been validated successfully on Catalina.

These warnings are not known to affect the tested functionality described above.
