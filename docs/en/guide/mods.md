# Mod Center

The mod center integrates OpenTTD's official content service **BaNaNaS** for browsing, downloading and managing game content.

## Content types

| Type | Description | Install location |
|------|-------------|------------------|
| NewGRF | New graphics/vehicles/industries | `content_download/newgrf/` |
| AI | Computer opponents | `content_download/ai/` |
| AI library | Shared AI libraries | `content_download/ai/` |
| GameScript | Scenario logic | `content_download/game/` |
| GS library | Shared GameScript libraries | `content_download/game/` |
| Sound / base sets | Music and base resources | `content_download/baseset/` |
| Scenarios | Prebuilt maps | `content_download/scenario/` |

## Browse & install

1. **Mod Center → Online**, filter by type (NewGRF / AI / GameScript / music sets) or search locally (name/author/description).
2. The detail page shows name, author, latest version, size and description, plus an **Open web page** button.
3. **About downloads**: the official BaNaNaS API does not expose direct download links (content is distributed only through the game's custom TCP protocol with unguessable CDN URLs). Two ways to install:
   - Click **Open web page** to view the package on bananas.openttd.org;
   - Use the game's built-in **Content Download** window — the launcher automatically detects game-downloaded content (the installed list scans `content_download/` live).
4. **Local import**: point "Import local file" at an existing `.tar` (BaNaNaS package) or `.grf`; it is copied into the version's matching directory.

The **Installed** tab merges game-downloaded and launcher-imported content, with size display and delete.

## Compatibility

- NewGRF compatibility depends on game version (major release, GRF feature bits). The detail page shows upstream-declared compatibility; **automatic detection** arrives in a later release.
- JGRPP-specific content needs JGRPP.
- Content installed through the game's own **Content Download** window shows up in the installed list too (directory scan) — both ways work side by side.

## Offline & cache

Content listings are cached in `cache/bananas/` (with TTL). Offline you can browse cached data and manage installed mods, but not download new ones.

## Credits

BaNaNaS is the OpenTTD community's official content service. Respect each mod's license; when a server uses a NewGRF, all players receive it automatically.
