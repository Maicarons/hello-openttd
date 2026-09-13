# Quick Start

Goal: an installed OpenTTD and a running game within 5 minutes.

## 1. Install your first version

1. Open **Version Management**.
2. Pick a source (default **OpenTTD official**; JGRPP and others available), click **Install**.
3. Choose a release (e.g. 14.1) and confirm the download.
4. The launcher does the rest: download (fastest mirror auto-selected) → SHA-256 verification → extraction → version manifest.

> 💡 During first install you pick a **config scheme**:
> - **Independent** (recommended): each version owns its `openttd.cfg`, saves and mods.
> - **Shared**: all versions use one config and one data set.
> Details in [Version Management](./versions#independent-vs-shared-config).

## 2. Launch

1. Select the version on **Home** or **Version Management**, hit **▶ Launch**.
2. Play.

Optionally configure the launch mode on the Launch page first:

- **New game** — straight into a random map
- **Load save** — pick a `.sav`
- **Join server** — enter `host[:port]`
- **Dedicated server** — headless mode

## 3. Add some mods (optional)

1. Open **Mod Center**, filter by type (NewGRF / AI / GameScript / sound sets / scenarios).
2. Search (e.g. `UK`, `2CC`), open the detail page, click **Install**.
3. Content lands in the version's `content_download/` — enable it in-game.

> ⚠️ Mind mod/game version compatibility — see [Mod Center](./mods#compatibility).

## 4. Tweak preferences

- **Language**: Settings → Language → 简体中文 / English.
- **Theme**: Settings → Theme → light / dark / system.
- **Slow downloads**: Settings → Downloads → add a mirror, see [Downloads & Mirrors](./downloads).

## 5. Next

- Understand [independent vs shared config](./versions#independent-vs-shared-config)
- Learn to [back up saves](./saves#backup-and-restore)
- Fine-tune the game with the [config editor](./config)
