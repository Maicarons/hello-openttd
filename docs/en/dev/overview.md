# Developer Overview & ADRs

Entry point of the developer docs: goals, scope, key engineering decisions (ADRs) and the doc map.

## Positioning

OpenDepot (repo `hello-openttd`) is a Flutter desktop launcher for OpenTTD, benchmarked against HMCL / PCL2, launching on Windows / Linux / macOS.

**In scope**

- Downloading, installing, updating and removing OpenTTD and its forks
- Launch-argument building and process management
- Viewing/editing `openttd.cfg` and related config files
- Browsing/downloading/managing BaNaNaS content
- Save browsing, import/export, backup/restore
- Launcher i18n, theming and settings

**Out of scope**

- Modifying or redistributing game binaries
- Backend-dependent features (server lists, relays) — everything runs locally
- Mobile / Web targets
- Fixing game bugs (route upstream)

## Milestones → specs

| Milestone | Content | Spec |
|-----------|---------|------|
| M1 Core | Skeleton, settings, i18n, theming, logging | [Architecture](./architecture), [Structure](./structure) |
| M2 Versions & downloads | Sources, download engine, install wizard | [Download engine](./download-engine) |
| M3 Launcher | Args, process monitoring, home deck | [Process](./process) |
| M4 Config | Parser, editor | [Config parser](./cfg-parser) |
| M5 Mods | BaNaNaS client | [BaNaNaS](./bananas) |
| M6 Saves | Browser, backup/restore | [Saves](./saves) |
| M7 Release | 3-platform artifacts, self-update | [Release](./release) |

## Architecture Decision Records

Lightweight ADR table; decisions append "revision" rows instead of rewriting history.

| # | Decision | Status | Rationale |
|---|----------|--------|-----------|
| ADR-001 | Flutter desktop first; Windows/Linux/macOS | Accepted | One codebase, three platforms; Dart covers HTTP/archive/process |
| ADR-002 | Riverpod, handwritten providers (no codegen) | Accepted | Compile-safe, testable, no build_runner chain |
| ADR-003 | go_router | Accepted | Declarative navigation |
| ADR-004 | Independent config via OpenTTD portable mode (cfg beside binary); shared via `-c` + directory links | Accepted | Uses native game behavior, zero intrusion |
| ADR-005 | zip via pure-Dart `archive`; `.tar.xz` via system `tar` on Linux (win/mac assets prefer zip) | Accepted | Avoids native xz bindings |
| ADR-006 | Mirrors = URL templates; file downloads only, API direct | Accepted | Templates are generic; API rewriting is fragile |
| ADR-007 | dio as HTTP client | Accepted | Interceptors, Range support |
| ADR-008 | JSON files for settings (not shared_preferences only) | Accepted | Portable, migratable, structured data needs files anyway |
| ADR-009 | Checksum trust model: fail-closed; pinned hashes first; unverified assets labeled | Accepted | See [Security](./security) |
| ADR-010 | VitePress bilingual docs (root zh + `/en/`), GitHub Pages | Accepted | Per project requirements |

## Tech-stack baseline

| Layer | Choice |
|-------|--------|
| SDK | Flutter stable (≥ 3.32) / Dart 3 |
| State | flutter_riverpod |
| Routing | go_router |
| Networking | dio |
| Archives | archive (zip); system tar (.tar.xz, Linux) |
| Hashing | crypto (SHA-256) |
| Paths | path, path_provider |
| i18n | flutter_localizations + intl (ARB) |
| Storage | local JSON files |
| Logging | logger + rolling files |
| Window | window_manager |
| Testing | flutter_test + mocktail + shelf |

## Conventions

- Code/comments/identifiers in English; every user-facing string goes through ARB (zh + en in sync).
- `flutter analyze --fatal-infos` clean is a merge gate.
- Conventional Commits; the PR template includes security self-checks.
- Minimal dependencies; new ones need justification in the PR; lockfiles committed.

## Doc map

```
docs/dev/
├── overview          this page (overview & ADRs)
├── setup             environment
├── structure         repo & code layout
├── architecture      layering, state, errors, i18n/theming
├── download-engine   mirrors / resume / verification
├── bananas           BaNaNaS integration
├── cfg-parser        openttd.cfg parser
├── process           process & launch
├── saves             save service
├── security          security design & threat model
├── testing           test strategy
└── release           release process
```
