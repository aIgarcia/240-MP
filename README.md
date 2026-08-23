<img src="https://github.com/user-attachments/assets/73c3e46f-a74a-4d96-9c4f-ae30f28378be" />

# 240-MP — Intel macOS Builds

Intel macOS builds of [240-MP](https://github.com/anthonycaccese/240-MP), the retro VCR-style media frontend created by Anthony Caccese.

This fork exists specifically to keep 240-MP usable on Intel Macs that are outside the macOS targets maintained by the upstream project.

For general information about 240-MP, its modules, configuration, hardware support and original documentation, please use the [upstream project](https://github.com/anthonycaccese/240-MP).

## Branches

| Branch | Purpose |
| --- | --- |
| `main` | Mirror of upstream 240-MP |
| `monterey-intel` | Intel x86_64 build for macOS Monterey |
| `catalina-intel` | Intel x86_64 build for macOS Catalina |

The Intel branches contain only the compatibility and packaging changes required for their respective macOS targets, plus a small set of playback improvements shared between them.

## macOS Catalina — Intel

Branch:

`catalina-intel`

Current base:

- 240-MP `v2026.08.17`
- macOS Catalina 10.15
- Intel x86_64
- Qt 6.4.2
- mpv 0.35.0

The release build has been tested on macOS Catalina 10.15.7 on Intel hardware.

### Catalina-specific work

The Catalina port includes:

- Qt 6.4 compatibility changes
- mpv 0.35 compatibility changes
- automatic installation and selection of the bundled VCR OSD Mono font
- Catalina-compatible subtitle handling
- improved mpv discovery
- bundled SDL2
- bundled mpv 0.35 runtime
- self-contained Qt/QML application packaging
- native macOS fullscreen fix
- expanded playback OSD
- reproducible release packaging

The Catalina release does not require a separately installed copy of mpv.

### Embedded mpv

Catalina release builds include an unmodified macOS x86_64 build of mpv 0.35.0 published by Stolendata and referenced by the official mpv installation documentation.

The packaging script downloads a pinned archive and verifies its SHA-256 before embedding the runtime.

Archive SHA-256:

`376415c787aef391a3927cdecd5bb0dac9f21ef9d7742516b8cd8d8ce502e7b6`

The mpv executable used in the tested release has SHA-256:

`b22994f6cabc81144fbc54f60e7959078bd5df8dbc27661ae046cbcc97a2a6a2`

Source, provenance and license information are preserved in:

- `THIRD_PARTY_NOTICES.md`
- `third_party/mpv-0.35.0/`

See `CHANGELOG-CATALINA.md` for the complete technical record.

### Tested on Catalina

The following have been exercised successfully on macOS Catalina 10.15.7:

- application startup and navigation
- Plex
- Jellyfin
- Local Files
- Ambient Mode
- Weather
- media playback
- embedded mpv
- expanded playback OSD
- VCR OSD Mono
- fullscreen
- application icon

The final standalone test was performed with the normal system mpv installation disabled. Plex and Ambient Mode both played media successfully using only the mpv runtime contained inside the 240-MP application bundle.

### Not validated on Catalina

YouTube / yt-dlp is not part of the validated Catalina release. yt-dlp is not currently bundled and remains future work.

NFC Reader has not been tested on Catalina.

Although some components used by this port can target macOS 10.14, the 240-MP application itself currently targets macOS 10.15. Mojave is therefore not a supported target.

## macOS Monterey — Intel

Branch:

`monterey-intel`

Current base:

- 240-MP `v2026.08.17`
- macOS Monterey
- Intel x86_64
- Qt 6.5.3

The Monterey port provides an Intel-native build of the current application while retaining the normal external mpv / yt-dlp model.

It also includes the shared Intel macOS playback work:

- native macOS fullscreen fix
- expanded playback OSD
- improved mpv discovery

The expanded OSD can expose additional playback information such as display title, video information, normalized frame rate, audio and subtitle information, and track position.

## Building Catalina releases

The Catalina branch includes `package-catalina-release.sh`.

A release can be produced with:

    ./package-catalina-release.sh v2026.08.17-intel-macos

The script performs the release build, Qt deployment, mpv download and verification, runtime embedding, third-party notice installation and final bundle validation.

The build itself is currently performed on macOS Monterey while targeting Intel macOS Catalina 10.15.

See `CHANGELOG-CATALINA.md` for exact build details and compatibility notes.

## Scope of this fork

This repository does not attempt to maintain alternative Raspberry Pi, SteamOS/Linux or Apple Silicon versions of 240-MP.

Those platforms, the complete module documentation, hardware information and general 240-MP documentation remain the responsibility of the upstream project.

Changes made here are intentionally limited to maintaining useful Intel macOS builds and the compatibility work required to support them.

## Upstream

240-MP is created and maintained by Anthony Caccese.

Upstream repository:

https://github.com/anthonycaccese/240-MP

Upstream documentation and wiki:

https://github.com/anthonycaccese/240-MP/wiki

## Development note

AI-assisted development and review were used during the Intel macOS porting and packaging work, together with manual build, runtime and hardware testing.

## License

240-MP is licensed under the GNU General Public License v3.0.

See `LICENSE` for the project license.

Bundled third-party components retain their respective licenses. Additional notices for the Catalina mpv runtime are available in `THIRD_PARTY_NOTICES.md`.
