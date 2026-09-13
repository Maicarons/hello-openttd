# Config Management

OpenTTD behavior is driven by `openttd.cfg` (INI-style). hello-openttd adds scheme management and a graphical editor.

## Config schemes

Chosen at install time, switchable per version later:

- **Independent**: each version directory carries its own `openttd.cfg` (plus `save/`, `content_download/` …) — maximum isolation.
- **Shared**: the launcher points every version at one global config via `-c`, and links mod/save directories into a shared store.

Switching schemes walks you through **migrating or copying** existing data — nothing is silently dropped.

## The graphical editor

The **Config page** shows a section tree on the left and typed forms on the right:

- **Typed controls**: switches for booleans, dropdowns for enums, ranged inputs for numbers, dedicated path/color pickers.
- **Bilingual docs**: every key has Chinese/English names and explanations (hover or side panel).
- **Search**: find keys by name or description ("autosave", "resolution" …).
- **Raw view**: direct text editing for advanced users; stays in sync with forms.
- **Change tracking**: unsaved edits are highlighted; saving runs validation (type, range, illegal characters) first.

The editor invents nothing: forms render from a built-in **key catalog**; unknown keys are edited in the raw view and never lost.

## Saving & backups

- Each save writes `openttd.cfg.bak-YYYYMMDDHHmmss` next to the file.
- The last 10 backups are listed and restorable.
- **Sensitive files**: `private.cfg` values (passwords) are masked and excluded from copy/export by default.

## Common keys cheat-sheet

| Section | Key | Effect |
|---------|-----|--------|
| misc | `language` | UI language |
| gui | `autosave` | Autosave interval (off/3/6/12 game months) |
| gui | `autosave_on_exit` | Save on exit |
| misc | `currency` | Currency unit |
| game_creation | `year` | Starting year |
| game_creation | `map_x` / `map_y` | Map size (2^n) |
| difficulty | `max_no_competitors` | Number of AI opponents (0-14) |
| vehicle | `max_trains` etc. | Vehicle limits |
| network | `client_name` | Multiplayer nickname |
| network | `server_name` | Server name (when hosting) |

> Keys and values are version-specific; forks like JGRPP add more — edit unknown keys in the raw view.

## Advanced

- Unknown sections/keys, comments and ordering are preserved — the parser is **line-preserving** (see the [parser spec](/en/dev/cfg-parser)).
- Full reset: delete `openttd.cfg` (the game regenerates it) or use "Restore defaults" on the config page.
