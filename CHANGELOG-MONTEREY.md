# 240-MP Monterey Intel — Changelog

This file documents changes maintained in this fork for the Intel
macOS Monterey build. Upstream 240-MP development remains the work of
Anthony Caccese and its contributors.

## v2026.08.17-monterey-intel.2 — 2026-08-22

Validated Intel x86_64 build for macOS Monterey 12, based on upstream
240-MP v2026.08.17 (`b434603`).

### Upstream base

Includes all upstream changes through v2026.08.17, including:

- configurable macOS launch display;
- Scripts module;
- Plex PIN-protected Home profile support;
- repeated skip while holding a key;
- settings navigation improvements;
- Plex server-token recovery;
- IP address display;
- Ambient Mode shuffle and auto-launch;
- expanded NFC Reader support;
- Weather module.

### Monterey Intel changes

- Builds as native Intel x86_64 with macOS Monterey 12 as deployment
  target.
- Uses Qt 6.5.3 for the Monterey build.
- Removes mpv `--no-native-fs` while retaining fullscreen playback,
  fixing the thin white border observed on macOS fullscreen playback.
- Preserves upstream configurable-display handling introduced in
  v2026.08.17.
- Adds an expanded playback OSD with:
  - useful media titles while filtering technical Plex URLs;
  - video codec;
  - simplified resolution;
  - aspect ratio;
  - normalized frame rate;
  - audio codec and Mono/Stereo/Surround classification;
  - current and total audio-track count;
  - useful audio-language metadata;
  - subtitle format and current/total subtitle-track count.
- Adds more robust mpv discovery for personal macOS installations,
  including PATH, common Homebrew locations, and mpv.app.

### Runtime requirements

The application bundle contains its required Qt runtime and QML
components.

mpv remains an external playback dependency.

yt-dlp remains an external dependency used for YouTube functionality.
Plex, Jellyfin, Emby, Local Files and Ambient Mode do not require
yt-dlp for their normal playback paths.

### Validated environment

- macOS Monterey 12
- Intel x86_64
- Qt 6.5.3
- AppleClang 14
- external mpv
- external yt-dlp

### Packaging

The validated standalone application is produced using a packaging
build (`CI=1`), followed by `cmake --install` and `macdeployqt`.

Development builds intentionally use a symlink from
`Contents/Resources` to the source tree and must not be used directly
as distributable application bundles.

## Previous Monterey Intel work

### v2026.07.12-monterey-intel.1

Initial Intel Monterey build.

- Native Intel x86_64 build.
- Initial fullscreen border fix.
- Initial expanded mpv playback OSD.
