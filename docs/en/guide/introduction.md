# Introduction

**hello-openttd** (working codename) is an open-source desktop **launcher for OpenTTD**, inspired by the mature HMCL / PCL2 launchers of the Minecraft ecosystem: installing a version, adding a mod and starting a game should take a few clicks — not unzip wars, forum spelunking and hand-editing config files.

> 🚧 The project is in its **documentation & architecture phase**; features ship according to the [roadmap](https://github.com/hello-openttd/hello-openttd/blob/main/ROADMAP.md).

## Why a launcher?

| Pain | hello-openttd's answer |
|------|--------------------|
| Playing official + JGRPP means manual downloads into separate folders | Multi-version management, isolated directories, one-click switching |
| GitHub downloads slow or unreachable | Built-in mirror acceleration (auto-select, resume, checksums) |
| Shared config across versions, changing one breaks the other | Independent/shared config schemes |
| Installing NewGRF/AIs means the BaNaNaS website and moving files | Built-in mod center with online browsing |
| `openttd.cfg` is cryptic and a typo bricks your game | Graphical editor with typed controls and ranges |
| Saves scattered around, backups by hand | Save browser + one-click backup/restore |

## Core features

- **📦 Multi-version management** — official OpenTTD, [JGRPP](https://github.com/JGRennison/OpenTTD-patches), CityMania Client (CMClient), other forks; custom sources supported.
- **⚡ Mirror-accelerated downloads** — best-source probing (GitHub official default, user mirrors), resumable, SHA-256 verified.
- **🔧 Config management** — independent/shared schemes; graphical `openttd.cfg` editor.
- **🎨 Mod management** — BaNaNaS content (NewGRF / AI / GameScript / sound sets / scenarios), unified local library.
- **🚀 Launcher** — one-click launch, argument builder, multi-instance, process monitoring.
- **🗺️ Save management** — browse, import/export, backup/restore, search.
- **🌐 i18n** — Simplified Chinese / English.
- **🎨 Theming** — light / dark / follow system.
- **🛡️ Hardening** — path-traversal protection, URL validation, file verification, dependency auditing (see [Security](/en/dev/security)).

## Platforms

| Platform | Status |
|----------|--------|
| Windows 10/11 (x64) | ✅ Launch |
| Linux (x64, AppImage/tar.gz) | ✅ Launch |
| macOS 12+ (universal) | ✅ Launch |

## Glossary

| Term | Meaning |
|------|---------|
| Version | One installed copy of OpenTTD (official or a fork) |
| Source | A channel that provides versions, e.g. GitHub Releases or a URL list |
| Mirror | A relay service that accelerates GitHub downloads |
| Independent config | Each version keeps its own `openttd.cfg` and data directories |
| Shared config | All versions share one configuration and data directories |
| Content | Downloadables on BaNaNaS: NewGRF, AIs, GameScripts, sound sets, scenarios |

## Relationship with OpenTTD

hello-openttd is a **community-built third-party launcher**, not affiliated with the OpenTTD team. It never modifies the game itself. Game bugs go to the [OpenTTD repository](https://github.com/OpenTTD/OpenTTD).

## Next steps

- [Install hello-openttd](./install)
- [Quick start: a game in 5 minutes](./quick-start)
