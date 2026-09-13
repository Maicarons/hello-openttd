# Config Parser Spec

`services/config/` parses, edits and rewrites OpenTTD config files (`openttd.cfg` primarily; `private.cfg` / `servers.cfg` recognized, not openly editable).

## 1. Format facts

INI-style: `[section]`, `key = value`, booleans `true/false`, comments preserved where present. The game **rewrites the whole file** on exit — hence "preserve structure" is the editor's core value. Sidecar files: `private.cfg` (sensitive client/server secrets), `servers.cfg` (known servers).

## 2. Line-preserving parsing (core decision)

No full-file regeneration: parse into a model with line references, mutate only targeted lines, keep comments/ordering.

```dart
class CfgDocument {
  final List<CfgLine> lines;
  final Map<String, CfgSection> sections;
}
sealed class CfgLine { CommentLine / BlankLine / SectionLine / KeyValueLine / UnknownLine }
```

- Tolerant parsing: ununderstood lines become `UnknownLine` and round-trip verbatim (**never drop user content**).
- UTF-8 in/out; BOM preserved.

## 3. Key catalog

Typed form data source, shipped with the launcher:

```yaml
- section: gui
  key: autosave
  type: enum            # bool | int | string | enum | path
  options: [off, "3", "6", "12"]
  labels: { zh: 自动保存间隔, en: Autosave interval }
```

- Covers **common keys**; unknown keys are edited in the raw view.
- Fork keys flagged via `flavors: [vanilla, jgrpp]` and surfaced per installed source.

## 4. Editing & validation

- **Form view**: switches/dropdowns/ranged inputs from the catalog.
- **Raw view**: text editing over the same document model, live sync.
- Pre-save validation: type, range, illegal characters (newlines/control chars rejected); failures list offending lines and block saving.
- **Automatic backup**: `openttd.cfg.bak-YYYYMMDDHHmmss`, last 10 kept.

## 5. Concurrency with the game

The game rewrites config on exit and can clobber edits:

1. Saving while a game from the same version dir is running → warn "exit the game first".
2. mtime tracked at load; changed underneath → prompt reload.

## 6. Sensitive files

- `private.cfg` secrets masked (`••••`), excluded from copy/export by default.
- `servers.cfg` read-only display.

## 7. Test points

- Round-trip: parse → save unchanged → **byte-identical** output (golden files).
- Single-key edit → minimal diff.
- Malformed inputs: empty, missing section headers, duplicate sections/keys, oversized lines — all parse and round-trip losslessly.
- Catalog completeness: types valid, bilingual labels present (CI-checked).
