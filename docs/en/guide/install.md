# Installation

hello-openttd itself is a portable desktop app — unzip and run.

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
| Windows | `hello-openttd-<ver>-windows-x64.zip` |
| Linux | `hello-openttd-<ver>-linux-x64.tar.gz` / `.AppImage` |
| macOS | `hello-openttd-<ver>-macos-universal.zip` |

> Releases also ship a `sha256sums.txt`; verifying is recommended (see [Downloads](./downloads#file-verification)).

### Windows

1. Unzip anywhere (a non-system drive such as `D:\hello-openttd` is recommended).
2. Run `hello_openttd.exe`.

### Linux

```bash
tar -xzf hello-openttd-*-linux-x64.tar.gz
cd hello-openttd
./hello_openttd
```

AppImage: `chmod +x hello-openttd-*.AppImage && ./hello-openttd-*.AppImage`

### macOS

1. Unzip and move `hello-openttd.app` into **Applications**.
2. On first launch, if macOS says the developer can't be verified (unsigned until M7): right-click the app → **Open**; or run:

```bash
xattr -cr /Applications/hello-openttd.app
```

## First launch

The launcher asks you to confirm the **data root** — where versions, backups and caches live:

| Platform | Default data root |
|----------|-------------------|
| Windows | `%APPDATA%\hello-openttd` |
| Linux | `~/.local/share/hello-openttd` (XDG) |
| macOS | `~/Library/Application Support/hello-openttd` |

**Portable mode**: place a folder named `hello-openttdData` (or an empty `portable.flag`) next to the launcher binary; it becomes the data root — perfect for USB sticks and sync folders. Migrate later in [Settings](./settings#data-root).

## Upgrade & uninstall

- **Upgrade**: overwrite the program files with the new bundle; the data root and installed versions are untouched.
- **Uninstall**: delete the program folder; delete the data root to remove everything (versions included).

## Troubleshooting

- Windows SmartScreen / missing DLL → [FAQ](./faq).
- Linux GTK errors → install `libgtk-3-0` etc., see [FAQ](./faq).
- macOS Gatekeeper → steps above and [FAQ](./faq).
