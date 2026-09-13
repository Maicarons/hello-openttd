# Version Management

The core page: browse, install, update and remove OpenTTD versions.

## Built-in sources

| Source | Content | Type | Verification |
|--------|---------|------|--------------|
| OpenTTD official | Stable releases via the project CDN (`latest.yaml`/`manifest.yaml`) | cdn.openttd.org | **Publisher SHA-256, verified end to end** |
| JGRPP | JGR's patch pack with many enhancements | GitHub Releases (`JGRennison/OpenTTD-patches`) | Hash recorded, labeled "unverified" |
| CMClient | CityMania client | GitHub Releases (`citymania-org/cmclient`) | Same |
| Custom | Any fork, user-added | GitHub Releases or URL list | Declared hashes enforced |

> The official source prefers the OpenTTD CDN — no rate limits and publisher-provided checksums, faster and more reliable than the GitHub API.

## Installing a version

1. **Version Management → Install**, pick a source (platform auto-detected).
2. The release list shows version, date and asset size.
3. Pick a release — the launcher resolves the platform asset (e.g. `openttd-14.1-windows-win64.zip`).
4. Pick a **config scheme** (independent / shared) → download starts.
5. Pipeline: **download (resumable) → SHA-256 verify → extract (Zip-Slip guarded) → write manifest**.
6. The version appears in the list, ready to launch.

When things fail:

- Interrupted download → **Resume** keeps fetched bytes.
- Checksum mismatch → install aborts immediately (fail-closed); retry via another mirror.
- Extraction/disk errors → check logs (Settings → Advanced → Open log folder).

## Update & remove

- **Update check** compares against the latest release; upgrades install into a new directory (the old one is kept until you clean it up).
- **Remove** deletes the version directory; independent configs/saves are offered for export first.

## Independent vs shared config

| | Independent (default) | Shared |
|---|---|---|
| `openttd.cfg` | One per version | One global |
| Saves / screenshots / mods | Per version | Shared by all versions |
| NewGRF compatibility risk | Low | Higher (changes hit every version) |
| Best for | Multi-version players | Single-version players wanting one save pool |

How it works (and where files live):

- **Independent**: OpenTTD prefers an `openttd.cfg` next to the executable (portable mode) — the launcher simply writes config into the version directory.
- **Shared**: the launcher passes `-c <shared config>` to every version and links `content_download/` and `save/` into the shared store via **directory links** (Windows junction / Unix symlink), falling back to copy-sync where links are unavailable.

## Version directory layout

```
<data-root>/
├── versions/
│   ├── official-14.1/
│   │   ├── openttd(.exe)
│   │   ├── openttd.cfg            # independent config
│   │   ├── content_download/
│   │   ├── save/
│   │   └── manifest.json          # launcher-maintained
│   └── jgrpp-0.61.2/...
├── shared/                        # shared-scheme data
│   ├── config/openttd.cfg
│   ├── mods/{baseset,newgrf,ai,game,scenario}/
│   ├── saves/
│   └── backups/
├── cache/downloads/
├── mirrors.json
├── settings.json
└── logs/
```

`manifest.json` records version, source, platform, install time and checksums — the launcher's source of truth; don't hand-edit.

## Custom sources

**Settings → Sources → Add**, two kinds:

**1. GitHub Releases** — `owner/repo` plus per-platform asset templates (`{version}` placeholder):

```text
windows-x64: openttd-{version}-windows-win64.zip
linux-x64:   openttd-{version}-linux-generic-amd64.tar.xz
macos:       openttd-{version}-macos-universal.zip
```

**2. URL list** — a JSON file hosted anywhere:

```json
[
  { "version": "1.2.3", "date": "2026-01-20",
    "assets": {
      "windows-x64": { "url": "https://example.com/cmclient-1.2.3-win64.zip", "sha256": "…" },
      "linux-x64":   { "url": "https://example.com/cmclient-1.2.3-linux.tar.gz", "sha256": "…" }
    } }
]
```

> ⚠️ Custom sources are only as trustworthy as their provider: HTTPS-only; declared `sha256` values are enforced, unverified assets are clearly labeled at install time.
