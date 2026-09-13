# Appearance & Language

Launcher preferences live in Settings.

## Language

- **简体中文** and **English**, defaulting to the system language (fallback: English).
- Switching takes effect **immediately**; the choice persists in `settings.json`.
- Missing keys fall back to English.

## Theme

| Option | Meaning |
|--------|---------|
| Light | Light theme |
| Dark | Dark theme |
| System (default) | Follows the OS appearance |

Material 3 throughout, one brand palette (OpenTTD green) driving both schemes; the window title bar adapts automatically.

## Data root

Shows the current data root with **migrate** and **open folder** actions. Portable-mode roots cannot be migrated (they follow the program folder).

## Downloads & mirrors

See [Downloads & Mirrors](./downloads): strategy, mirror management, probing, GitHub token.

## Advanced

- **Log level**: info (default) / debug / trace
- **Open log folder**
- **Diagnostic bundle**: zips logs + a sanitized environment summary for Issues (**no** tokens, no save content)
- **Reset launcher settings**: resets `settings.json` only; versions and saves untouched
- **Check for launcher updates**: manual trigger (no background checks in v1)

## Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+1..8` | Switch main navigation pages |
| `Ctrl+,` | Open settings |
| `Ctrl+R` / `F5` | Refresh current page |
