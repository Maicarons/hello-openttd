# Installation

OpenDepot itself is a portable desktop app — unzip and run.

## Requirements

| Platform | Requirement |
|----------|-------------|
| Windows | Windows 10 1809+ (x64) |
| Linux | Mainstream distros (GTK3 runtime, e.g. `libgtk-3-0`) |
| macOS | macOS 12+ (universal: Intel + Apple Silicon) |

The game (OpenTTD / JGRPP / …) does **not** need to be pre-installed — the launcher downloads it.

## Get the launcher

Grab your platform bundle from GitHub Releases:

| Platform | Artifact |
|----------|----------|
| Windows | `OpenDepot-<ver>-windows-x64.zip` |
| Linux | `OpenDepot-<ver>-linux-x64.tar.gz` / `.AppImage` |
| macOS | `OpenDepot-<ver>-macos-universal.zip` |

> Releases also ship a `sha256sums.txt`; verifying is recommended (see [Downloads](./downloads#file-verification)).

### Windows

1. Unzip anywhere (a non-system drive such as `D:\OpenDepot` is recommended).
2. Run `opendepot.exe`.

### Linux

```bash
tar -xzf OpenDepot-*-linux-x64.tar.gz
cd OpenDepot
./opendepot
```

AppImage: `chmod +x OpenDepot-*.AppImage && ./OpenDepot-*.AppImage`

### macOS

1. Unzip and move `OpenDepot.app` into **Applications**.
2. On first launch, if macOS says the developer can't be verified (unsigned until M7): right-click the app → **Open**; or run:

```bash
xattr -cr /Applications/OpenDepot.app
```

## First launch

The launcher asks you to confirm the **data root** — where versions, backups and caches live:

| Platform | Default data root |
|----------|-------------------|
| Windows | `%APPDATA%\OpenDepot` |
| Linux | `~/.local/share/opendepot` (XDG) |
| macOS | `~/Library/Application Support/OpenDepot` |

**Portable mode**: place a folder named `OpenDepotData` (or an empty `portable.flag`) next to the launcher binary; it becomes the data root — perfect for USB sticks and sync folders. Migrate later in [Settings](./settings#data-root).

## Upgrade & uninstall

- **Upgrade**: overwrite the program files with the new bundle; the data root and installed versions are untouched.
- **Uninstall**: delete the program folder; delete the data root to remove everything (versions included).

## Troubleshooting

- Windows SmartScreen / missing DLL → [FAQ](./faq).
- Linux GTK errors → install `libgtk-3-0` etc., see [FAQ](./faq).
- macOS Gatekeeper → steps above and [FAQ](./faq).
