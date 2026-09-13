# Testing Strategy

## Principles

- **Core logic testable with zero network and zero UI**: services take injected dependencies (HTTP, filesystem root, clock).
- Merge gates: `flutter analyze --fatal-infos` clean + `flutter test` green + tests for new core logic.
- Coverage target: `lib/services` + `lib/data` ≥ 70% (reported in CI, non-blocking, trending up).

## Layer matrix

| Layer | Type | Covers |
|-------|------|--------|
| `core/paths` | unit | filename validation, `safeJoin` escape fuzzing |
| `services/download` | unit + integration | Range resume, mirror selection, checksum failure, retry backoff |
| `services/version_source` | unit | API response fixtures, asset template matching |
| `services/bananas` | unit | type mapping, layout, mods.json round-trip |
| `services/config` | unit | line-preserving round-trip (golden), edit diffs, malformed input |
| `services/process` | unit | argument builder (pure) + fake process lifecycle |
| `services/saves` | unit + perf | scanning, backup round-trip, name fuzz, 10k-file baseline |
| `data/repositories` | unit | schema migrations (v1→v2) |
| UI | widget (sparse) | theme/locale switching, AsyncValue error views |
| End-to-end | manual checklist | per release (see [Release](./release)) |

## Test infrastructure

**Local HTTP server** (`package:shelf`) simulating real semantics:

- `206 Partial Content` / `Content-Range` (resume)
- ETag changes (resume invalidation)
- Slow responses / dropped connections (retry, timeouts)
- Checksum pass/fail flows

**Fixtures**: small zip/tar.gz/cfg samples under `test/fixtures/` (< 100 KB); recorded GitHub/BaNaNaS responses as JSON fixtures with capture dates; fake game executables (`.cmd`/`.sh`) scripted to log and exit with a code.

**Time & randomness**: injected `Clock`, fixed seeds — no direct `DateTime.now()` in tests.

## Running

```bash
flutter test
flutter test test/services/download/
flutter test --coverage                 # CI uploads lcov
flutter test --update-goldens           # local only, commit with PR
```

## Manual acceptance checklist (per release)

1. Fresh install on all three platforms → data root → install official → launch → new game
2. Resume: interrupt a download → resume continues
3. Mirror fallback: dead mirror → falls back to official
4. Checksum failure: tampered fixture → clear error, no partial install
5. Independent/shared config: two versions isolated or shared as configured
6. Config editor: change `autosave` → verified in game; `.bak` created
7. Mods: BaNaNaS install → usable in game; uninstall removes it
8. Saves: backup → delete → restore
9. i18n/theming: both languages, both themes, all pages — no overflow/missing keys
10. Multi-instance: two runs coexist (independent config)
