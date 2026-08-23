<img src="https://github.com/user-attachments/assets/73c3e46f-a74a-4d96-9c4f-ae30f28378be" />

# 240-MP — Intel macOS Builds

Intel macOS builds of [240-MP](https://github.com/anthonycaccese/240-MP),
the retro VCR-style media frontend created by Anthony Caccese.

This fork exists specifically to keep 240-MP usable on Intel Macs outside
the macOS targets maintained by the upstream project.

For general information about 240-MP, its modules, configuration,
hardware support and original documentation, use the
[upstream project](https://github.com/anthonycaccese/240-MP).

## Branches

| Branch | Purpose |
| --- | --- |
| `main` | Mirror of upstream 240-MP |
| `monterey-intel` | Intel x86_64 build for macOS Monterey |
| `catalina-intel` | Intel x86_64 build for macOS Catalina |

`main` is intentionally kept aligned with upstream.

Intel-specific compatibility, packaging and release work lives only in
the Intel branches.

## macOS Monterey — Intel

Branch:

`monterey-intel`

Current release:

`v2026.08.17-intel-macos`

Base:

- 240-MP `v2026.08.17`
- upstream commit `b434603`
- macOS Monterey 12
- Intel x86_64
- Qt 6.5.3

The Monterey build retains the normal external mpv / yt-dlp runtime
model.

The branch includes:

- native Intel x86_64 support;
- macOS 12.0 deployment target;
- native macOS fullscreen fix;
- expanded playback OSD;
- improved mpv discovery for GUI launches;
- standalone Qt/QML packaging;
- bundled SDL2 runtime;
- bundled OpenSSL crypto runtime;
- repeatable release packaging.

See `CHANGELOG-MONTEREY.md` for the detailed release history and
validation record.

### Monterey runtime dependencies

The release application contains the Qt/QML, SDL2 and OpenSSL components
required by 240-MP itself.

mpv is external.

The validated Monterey build used:

`mpv 0.39.0`

240-MP searches for mpv in the application directory, `PATH`, common
Homebrew locations and standard `mpv.app` locations.

yt-dlp is also external and is required for YouTube functionality.

### Monterey validation

The final Monterey application was tested on Intel macOS Monterey.

The validation included:

- application startup and navigation;
- Plex playback;
- Local Files playback;
- Ambient Mode playback;
- expanded playback OSD;
- fullscreen playback;
- normal external mpv discovery;
- fallback discovery of `/Applications/mpv.app/Contents/MacOS/mpv`.

The fallback test was performed with `/usr/local/bin/mpv` temporarily
disabled. Playback continued successfully using the standalone
`/Applications/mpv.app` installation.

Validated Monterey executable SHA-256:

`6f02b201a5e79e36807d094682e2dfa3507f8f9393b1b295a5c7198f90e2ef31`

The checksum identifies the tested release binary. Builds made with
different compiler, SDK or dependency revisions are not expected to be
byte-for-byte reproducible.

## Rebuilding Monterey from a clean clone

The Monterey branch includes:

`package-monterey-release.sh`

The build assumes that the required development tools are already
installed.

The validated toolchain uses:

- Xcode Command Line Tools / AppleClang 14;
- CMake;
- Homebrew;
- Qt 6.5.3;
- Homebrew `openssl@3`;
- Homebrew `sdl2-compat`.

By default the packaging script expects Qt at:

`~/Qt/6.5.3/macos`

An alternate Qt installation can be selected with `QT_ROOT`.

Starting from a clean clone:

    git clone https://github.com/aIgarcia/240-MP.git
    cd 240-MP
    git checkout monterey-intel
    ./package-monterey-release.sh v2026.08.17-monterey-intel.3

The completed application is written to:

`dist-monterey-release/240mp.app`

The script creates a fresh build directory each time and performs the
complete configure, build, install, Qt deployment, signing and validation
sequence.

For normal playback, install a compatible external mpv build separately.

## macOS Catalina — Intel

Branch:

`catalina-intel`

Current release:

`v2026.08.17-intel-macos`

Base:

- 240-MP `v2026.08.17`
- upstream commit `b434603`
- macOS Catalina 10.15
- Intel x86_64
- Qt 6.4.2
- mpv 0.35.0

The Catalina port contains additional compatibility work required by the
older operating system, Qt version and mpv runtime.

Unlike Monterey, the Catalina release embeds its validated mpv 0.35.0
runtime directly inside the 240-MP application bundle.

The Catalina release has been tested on macOS Catalina 10.15.7 on Intel
hardware.

Detailed Catalina documentation is maintained on the `catalina-intel`
branch.

Catalina changelog:

https://github.com/aIgarcia/240-MP/blob/catalina-intel/CHANGELOG-CATALINA.md

### Rebuilding Catalina from a clean clone

The Catalina branch contains:

`package-catalina-release.sh`

Starting from a clean clone on a build machine with the documented
Catalina toolchain available:

    git clone https://github.com/aIgarcia/240-MP.git
    cd 240-MP
    git checkout catalina-intel
    ./package-catalina-release.sh v2026.08.17-catalina-intel.1

The packaging workflow builds the application, deploys Qt, downloads the
pinned mpv 0.35.0 archive, verifies its SHA-256, embeds the mpv runtime,
installs the required third-party notices and validates the completed
bundle.

The validated Catalina release is built on macOS Monterey while targeting
Intel macOS Catalina 10.15.

## Release philosophy

The Intel branches are intended to remain reconstructable from source.

The expected workflow is:

1. Install the documented build tools and dependencies.
2. Clone this fork.
3. Check out the desired Intel branch.
4. Run that branch's release-packaging script.
5. Obtain a standalone application bundle suitable for testing or
   distribution.

Release checksums identify the exact binaries that were manually tested.

They are not used as a requirement that independent builds made with
different compiler or dependency revisions must be byte-for-byte
identical.

## Scope of this fork

This repository does not attempt to maintain alternative Raspberry Pi,
SteamOS/Linux or Apple Silicon versions of 240-MP.

Those platforms, the complete module documentation, hardware information
and general 240-MP documentation remain with the upstream project.

Changes maintained here are intentionally limited to useful Intel macOS
builds, compatibility work required by those systems, release packaging,
and the small set of playback improvements shared by the Intel builds.

## Upstream

240-MP is created and maintained by Anthony Caccese.

Upstream repository:

https://github.com/anthonycaccese/240-MP

Upstream documentation and wiki:

https://github.com/anthonycaccese/240-MP/wiki

This fork is downstream of the original project. Upstream is used as the
source for base releases and future synchronization; Intel-specific
release work is maintained in this fork.

## Development note

AI-assisted development and review were used during the Intel macOS
porting, packaging and documentation work, together with manual build,
runtime and hardware testing.

## License

240-MP is licensed under the GNU General Public License v3.0.

See `LICENSE` for the project license.

Bundled third-party components retain their respective licenses.
Catalina-specific mpv provenance and notices are maintained on the
`catalina-intel` branch.
