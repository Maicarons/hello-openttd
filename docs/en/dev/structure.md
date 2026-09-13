# Project Structure

## Repository

```
hello-openttd/
├── .github/
│   ├── workflows/
│   │   ├── deploy-docs.yml      # VitePress → GitHub Pages
│   │   └── ci.yml               # Flutter analyze + test (3-OS matrix, path-filtered)
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── dependabot.yml
├── docs/                        # VitePress (zh at root + en/)
├── lib/                         # Flutter app (lands in M1)
├── test/
├── windows/ linux/ macos/       # platform shells (flutter create)
├── LICENSE                      # AGPL-3.0
├── CONTRIBUTING.md / SECURITY.md / CODE_OF_CONDUCT.md
├── ROADMAP.md / CHANGELOG.md
├── pubspec.yaml
└── analysis_options.yaml
```

## Flutter code layout (planned)

Layered + feature-packaged: `core/data/services` are technical layers, `features` are page domains; one-way dependencies; UI reaches services only through providers.

```
lib/
├── main.dart                    # init logging/paths/settings, runApp
├── app.dart                     # MaterialApp.router: routes, i18n, theme
├── core/
│   ├── constants.dart
│   ├── paths/
│   │   ├── app_paths.dart       # data root resolution, portable mode
│   │   └── fs_guard.dart        # path validation (see Security)
│   ├── errors/failures.dart     # sealed failure types
│   ├── logging.dart             # rolling file logs
│   └── utils/
├── data/
│   ├── models/                  # plain classes + JSON (handwritten)
│   └── repositories/            # JSON file stores
├── services/                    # domain services (UI-free, unit-testable)
│   ├── version_source/          # github_release / url_list adapters
│   ├── download/                # engine: mirrors, Range resume, SHA-256
│   ├── archive/                 # extraction with zip-slip guards
│   ├── bananas/
│   ├── config/                  # openttd.cfg parse/write
│   ├── process/
│   ├── saves/
│   └── security/                # URL validation, hashing
├── providers/                   # Riverpod wiring
├── features/
│   ├── home/ versions/ launch/ config_editor/ mods/ saves/ settings/
├── ui/
│   ├── theme/
│   ├── widgets/
│   └── layout/app_shell.dart    # NavigationRail shell
└── l10n/
    ├── app_en.arb
    └── app_zh.arb
```

## Dependency rules

```
features/ui → providers → services → data(core)
                                 ↘ core
```

- `core` depends on nothing above it.
- Services reference each other via abstract interfaces only; no cycles.
- UI/features never touch `File`/`Process` directly — always through services.

## Placement conventions

| Content | Location |
|---------|----------|
| New page | `features/<domain>/pages/` + route in `app.dart` |
| New service | `services/<domain>/` + interface + provider |
| New JSON structure | `data/models/` + `schemaVersion` + migration note |
| ARB keys | domain prefix, e.g. `versionsInstallTitle` |
| Tests | mirror `lib/`: `test/services/download/…` |
