# BaNaNaS Integration Spec

`services/bananas/` provides BaNaNaS browsing, search and local content management.

## 1. Upstream facts (confirmed against openttd-manager-plus and the bananas-api)

- **Metadata API**: `https://bananas-api.openttd.org/package/{type}` (list), `/package/{type}/{unique-id}` (detail); types include `newgrf / ai / game-script / base-music`.
- **Key limitation**: the API **exposes no direct download links**. Content ships only through the game's custom TCP protocol; CDN URLs are unguessable by design.
- Launcher v1 therefore offers **browse / search / detail / web-jump / local import / installed management**; byte-level downloads stay with the game's Content Download window.
- Future: a self-hosted mirror-server (see openttd-manager-plus' implementation, which implements the TCP protocol server-side and exposes `/bananas/{type}/{id}`) can be attached as an optional content source (v2).

## 2. Abstraction

```dart
class BananasService {
  Future<List<BananasPackage>> browse(String type, {bool forceRefresh});  // API + disk cache
  String webPageUrl(String type, String uniqueId);
  List<InstalledContentFile> scanInstalled(String gameDir);
  String importLocal(String gameDir, String sourceFile);                  // .tar/.grf
  void deleteInstalled(String gameDir, String relativePath);
}
```

- Listings cached in `cache/bananas/{type}.json` (TTL 6 h; stale cache served offline).
- Search is a local substring filter over name/author/description (the API has no server-side search).

## 3. Install layout

| ContentType | Target directory |
|-------------|------------------|
| baseGraphics / baseSounds / baseMusic | `content_download/baseset/` |
| newgrf | `content_download/newgrf/` |
| ai / aiLibrary | `content_download/ai/` |
| gameScript / gsLibrary | `content_download/game/` |
| scenario | `content_download/scenario/` |

Install = unzip the BaNaNaS package (zip-slip guarded) into the target + register `mods.json`:

```json
{ "schemaVersion": 1,
  "items": [ {
    "id": "ukrs", "type": "newgrf", "name": "UK Railway Set",
    "version": "3.1.1", "md5": "…",
    "files": ["content_download/newgrf/ukrs-3.1.1.tar"],
    "installedAt": "2026-09-13T12:00:00Z",
    "installedTo": "official-14.1", "source": "bananas" } ] }
```

**Uninstall**: delete exactly the recorded `files` (never directory scans); confirmation required.

## 4. Installed scan

The "Installed" page merges:

1. `mods.json` (launcher-installed/imported)
2. **Directory scan** of `content_download/*` (content installed by the game's own window)

Scan results deduplicate per file; game-installed entries show `source: game` with delete-only actions.

## 5. Local import

- `.tar` (BaNaNaS packages) and bare `.grf` via drag-and-drop or file picker.
- Imports register in `mods.json` (`source: "local"`, md5 computed locally).

## 6. Dependencies & compatibility (v2)

- BaNaNaS metadata carries library dependencies and version ranges: v1 displays them; v2 auto-installs dependencies and warns on incompatibility.
- `CompatibilityChecker` interface reserved for NewGRF/game matching.

## 7. Failure modes

| Case | Behavior |
|------|----------|
| API unreachable | Offline notice + cached listings |
| Interrupted download | Engine resumes |
| md5 mismatch | fail-closed, discard partials |
| Unwritable target | Extract to temp then atomic move; no partial installs |

## 8. Etiquette

Respect content licenses (shown on detail pages); rate-limit requests; identify as `OpenDepot/<version>`; cache listings to be gentle on the service.
