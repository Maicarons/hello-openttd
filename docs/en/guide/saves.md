# Save Management

Central management of saves for the selected version (independent mode) or the shared store (shared mode).

## Browse & search

- Scanned: `save/` (including `save/autosave/`), `scenario/`, `heightmap/`.
- Columns: name, size, modified time, origin directory; autosaves grouped.
- **Search** by name; sort by time/size/name.
- Quick actions: reveal in file manager, rename, delete (to the recycle bin).

## Metadata

List data comes from the filesystem (name, time, size). In-save **game date / companies / save version** require parsing the `.sav` format and will be provided best-effort (parse failures never break listing).

## Import / export

- **Import**: pick `.sav` / `.scn` files to copy into the version's save directory; name collisions auto-suffix (`xxx-1.sav`) or overwrite with confirmation.
- **Export**: copy saves anywhere; multi-select zip export for sharing.
- Batch operations supported.

## Backup and restore

Backups cover accidental deletion/corruption and device migration.

**Manual**: select saves → backup, or back up the whole directory.

**Automatic** (Settings → Saves):

| Option | Meaning |
|--------|---------|
| Trigger | Before each game launch / daily / manual only |
| Retention | Keep at most N (default 20), oldest cleaned first |
| Location | `<data-root>/shared/backups/` |

**Format**: a zip containing the saves plus `manifest.json` (time, version, file list with hashes) — restorable without the launcher.

**Restore**: pick a backup → verify manifest/hashes → existing files get an automatic safety copy → unpack. Cross-version restore is supported.

## Migration tips

- New computer: export backup zips + the shared saves directory.
- Removing a version never touches backups — they live independently.
