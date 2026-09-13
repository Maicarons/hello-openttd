# Setup

## Prerequisites

### Common

- **Flutter SDK** stable (`flutter --version` ≥ 3.32 / Dart ≥ 3.8). Pin the team version with [fvm](https://fvm.app).
- **IDE**: Android Studio / VS Code + Flutter plugin.
- **Node.js ≥ 20** for the docs site (`docs/` only).

### Platform toolchains

| Platform | Requirement |
|----------|-------------|
| Windows | Visual Studio 2022 with **Desktop development with C++** |
| Linux | `clang cmake ninja-build pkg-config libgtk-3-dev` (Ubuntu/Debian) |
| macOS | Xcode + Command Line Tools |

Cross-compiling isn't supported — each artifact builds on its own platform runner (see [Release](./release)).

## Clone & verify

```bash
git clone https://github.com/hello-openttd/hello-openttd.git
cd hello-openttd

flutter doctor
flutter devices     # windows / linux / macos desktop should appear
```

## Running (once the Flutter app lands)

```bash
flutter pub get
flutter run -d windows    # or -d linux / -d macos
```

## Docs site

```bash
cd docs
npm install
npm run dev        # http://localhost:5173/hello-openttd/
npm run build
npm run preview
```

> `base` is `/hello-openttd/` (matches the repo name). If you fork under another name, update `base` in `docs/.vitepress/config.mts` or Pages assets will 404.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| flutter doctor missing Visual Studio | Install VS2022 Community + C++ workload |
| Linux: `gtk/gtk.h not found` | `sudo apt install libgtk-3-dev ninja-build` |
| macOS signing errors | `flutter config --enable-macos-desktop`; Debug builds auto-sign locally |
| Docs dev port busy | `npm run dev -- --port 5174` |
| Slow Flutter/npm in some regions | Set `FLUTTER_STORAGE_BASE_URL`, `PUB_HOSTED_URL`, npm mirror |

## Git workflow

1. Branch from `main`: `feat/`, `fix/`, `docs/`, `refactor/`.
2. Conventional Commits (see [CONTRIBUTING](https://github.com/hello-openttd/hello-openttd/blob/main/CONTRIBUTING.md)).
3. Before a PR: `flutter analyze` clean, `flutter test` green, docs updated in both languages.
