# OpenDepot 🚂

> **OpenDepot** (working codename, repository name `hello-openttd`) is a modern desktop launcher for [OpenTTD](https://www.openttd.org/), bringing the HMCL / PCL2-style Minecraft launcher experience to OpenTTD: multi-version management, mirror-accelerated downloads, a mod store, a config editor and save management — batteries included.

<div align="center">

**🚀 v0.1.0 released**: version management, mirror-accelerated downloads, launcher, config editor, mod center and save management are all implemented (see the [CHANGELOG](./CHANGELOG.md)).

[![Docs](https://img.shields.io/badge/docs-VitePress-646cff?logo=vite&logoColor=ffd62e)](./docs/en/index.md)
[![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)](#)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📦 Multi-version management | Official OpenTTD, JGRPP, CityMania Client (CMClient) and other forks |
| ⚡ Mirror-accelerated downloads | Automatic best-mirror selection (GitHub official source, user-extensible), resumable transfers, SHA-256 verification |
| 🔧 Config management | Independent / shared configuration schemes, graphical `openttd.cfg` editor |
| 🎨 Mod management | Browse & download BaNaNaS content (NewGRF/AI/GameScript/sound sets) with unified local management |
| 🚀 Launcher | One-click launch, argument builder, multi-instance, process monitoring |
| 🗺️ Save management | Browse, import, export, back up, restore and search savegames |
| 🌐 i18n | Simplified Chinese and English, switchable at runtime |
| 🎨 Theming | Light / dark theme |
| 🛡️ Security hardening | Path-traversal protection, URL validation, file verification, dependency auditing |

## 📚 Documentation

Documentation is built with VitePress (bilingual, maintained in `docs/`, auto-deployed to GitHub Pages via GitHub Actions). English docs: [docs/en](./docs/en/index.md).

```bash
# Preview the docs site locally
cd docs
npm install
npm run dev
```

## 🛠️ Tech Stack

- **Framework**: Flutter (desktop stable) + Dart 3 — Windows / Linux / macOS first
- **State**: Riverpod · **Routing**: go_router · **Networking**: dio
- **i18n**: flutter_localizations + ARB (`zh-Hans` / `en`)
- **Docs**: VitePress on GitHub Pages
- **License**: AGPL-3.0

## 🚀 Contributing

Read the [contributing guide](./CONTRIBUTING.md) and the [developer docs](./docs/en/dev/overview.md) first.

## 📄 License & Disclaimer

Licensed under the [GNU AGPL-3.0](./LICENSE).

**Disclaimer**: This is a community-built third-party launcher, not affiliated with the OpenTTD team, JGRPP, CityMania or BaNaNaS. OpenTTD and related assets belong to their respective authors.
