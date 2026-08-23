# 240-MP Monterey Intel — Changelog

This file documents the Intel macOS Monterey work maintained in this fork.

Upstream 240-MP remains the work of Anthony Caccese and its contributors.

## v2026.08.17 — Monterey Intel

Public Intel macOS release tag:

`v2026.08.17-intel-macos`

Intel x86_64 build for macOS Monterey 12 based on upstream 240-MP
v2026.08.17 (`b434603`).

### Upstream base

- 240-MP v2026.08.17
- upstream commit `b434603`

### Monterey Intel changes

The Monterey branch includes:

- native Intel x86_64 support;
- macOS 12.0 deployment target;
- Qt 6.5.3;
- native macOS fullscreen fix;
- expanded playback OSD;
- improved external mpv discovery;
- standalone Qt/QML packaging;
- bundled OpenSSL crypto runtime;
- bundled SDL2 runtime;
- repeatable release packaging.

### Fullscreen

The macOS playback configuration allows native fullscreen behavior instead
of forcing the previous non-native fullscreen mode.

This corrects the thin white border observed around fullscreen playback on
macOS.

### Playback OSD

The Intel macOS build includes an expanded playback OSD that can expose:

- useful display titles while filtering technical Plex URLs;
- video codec;
- simplified resolution;
- aspect ratio;
- normalized frame rate;
- audio codec;
- Mono/Stereo/Surround classification;
- current and total audio-track count;
- useful audio-language metadata;
- subtitle format;
- current and total subtitle-track count.

### mpv discovery

mpv remains an external runtime dependency on Monterey.

240-MP searches for mpv in this order:

1. An executable named `mpv` beside the 240-MP executable
2. The application environment `PATH`
3. `/usr/local/bin/mpv`
4. `/opt/homebrew/bin/mpv`
5. `/Applications/mpv.app/Contents/MacOS/mpv`
6. `~/Applications/mpv.app/Contents/MacOS/mpv`

This is useful for graphical macOS launches because GUI applications can
inherit a more restricted `PATH` than interactive shells.

The fallback to `/Applications/mpv.app/Contents/MacOS/mpv` was explicitly
tested with `/usr/local/bin/mpv` temporarily disabled. Playback continued
successfully.

### Runtime model

The standalone Monterey application contains the Qt/QML runtime, OpenSSL
crypto library and SDL2 required by 240-MP itself.

mpv is not bundled.

yt-dlp is not bundled and is required for YouTube functionality.

### Build environment used for the validated application

- macOS Monterey 12
- Intel x86_64
- AppleClang 14
- Qt 6.5.3
- OpenSSL 3
- SDL2 through `sdl2-compat`
- mpv 0.39.0

The validated application executable targets:

- architecture: x86_64
- minimum macOS: 12.0
- SDK: 13.1

### Release packaging

The branch includes:

`package-monterey-release.sh`

The script performs a clean standalone build and:

- builds in Release mode;
- targets Intel x86_64;
- uses macOS 12.0 as the deployment target;
- uses Qt 6.5.3;
- uses `CI=1` so application resources are copied into the bundle;
- runs `cmake --install`;
- runs `macdeployqt`;
- installs `qt.conf`;
- deploys the required Qt/QML runtime;
- bundles OpenSSL crypto;
- bundles SDL2;
- applies an ad-hoc macOS code signature;
- verifies the completed signature;
- checks required runtime files;
- checks the main executable for non-system absolute dependencies;
- checks the main executable for development-machine paths;
- reports the Mach-O deployment target and SDK;
- reports the executable SHA-256;
- reports the embedded application version.

mpv and yt-dlp remain external.

### Validation

The final Monterey application was exercised successfully with:

- application startup and navigation;
- Plex playback;
- Local Files playback;
- Ambient Mode playback;
- expanded playback OSD;
- fullscreen playback;
- mpv through `/usr/local/bin/mpv`;
- fallback mpv discovery through `/Applications/mpv.app/Contents/MacOS/mpv`.

YouTube and NFC Reader were not part of the final validation pass.

The validated application executable has SHA-256:

`6f02b201a5e79e36807d094682e2dfa3507f8f9393b1b295a5c7198f90e2ef31`

This checksum identifies the exact application executable used to create
the published Monterey DMG.

Independent rebuilds are not expected to be byte-for-byte identical when
compiler, SDK or dependency revisions differ.
