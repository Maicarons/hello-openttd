# Save Service Spec

`services/saves/`: scanning, metadata, import/export, backup/restore.

## 1. Scanned locations

| Directory | Content |
|-----------|---------|
| `<version>/save/` | manual `.sav` |
| `…/save/autosave/` | autosaves |
| `…/scenario/` | `.scn` |
| `…/heightmap/` | `.png` heightmaps |

Independent mode scans version dirs; shared mode scans the shared store; external directories can be mounted read-only for browsing.

## 2. Metadata (tiered)

- **v1 (M6)**: filesystem data — name, size, mtime, origin; search = name match; sort = time/size/name.
- **v2 (best effort)**: parse `.sav` headers for in-game date, save format version, etc. Implementation notes:
  - OpenTTD saves are a custom LZ-compressed container with magic + version in the header;
  - parse failures silently degrade to v1 — listing never breaks;
  - deep parsing runs in an Isolate with a per-file timeout (≤ 200 ms);
  - before v2 lands, byte layout must be verified against OpenTTD source (`saveload/`) and documented here.

## 3. Import / export / delete

| Operation | Rule |
|-----------|------|
| Import | `.sav/.scn` only; collision → auto-suffix or confirmed overwrite; copy (never move) |
| Export | Copy to a chosen directory; multi-select zip export |
| Rename | Filename charset validation (see [Security](./security)); no path separators |
| Delete | To the recycle bin (per-OS trash or launcher `.trash/`), purged after 30 days |

## 4. Backup

**Archive format**: zip with `manifest.json` (time, source version, file list + per-file sha256, launcher version) and `files/` preserving relative paths.

- **Triggers**: manual / before launch (configurable) / daily.
- **Retention**: keep N (default 20), oldest pruned; prunes audited in logs.
- **Location**: `<data-root>/shared/backups/` — independent of version directories.

**Restore**:

1. Verify `manifest.json` + per-file sha256;
2. Existing files at the target get an automatic safety copy first;
3. Unpack and overwrite; cross-version restore supported.

## 5. Performance

- Async scanning (enumeration + `stat`); 10k files < 1 s; > 5000 entries in an Isolate.
- Virtualized list (`ListView.builder`); compression in an Isolate with progress.

## 6. Tests

- Backup round-trip incl. tampered-file detection.
- Scan performance baseline regression.
- Filename fuzzing (Unicode, separators, Windows reserved names).
