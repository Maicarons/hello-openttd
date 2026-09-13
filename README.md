# hello-openttd 🚂

> **hello-openttd**（工作代号，仓库名 `hello-openttd`）是一个现代化的 [OpenTTD](https://www.openttd.org/) 桌面启动器，目标是把类 MC 启动器（HMCL / PCL2）的优秀体验带到 OpenTTD：多版本管理、镜像加速、模组商店、配置编辑器、存档管理，开箱即用。

<div align="center">

**🚀 v0.1.0 已发布**：版本管理 / 镜像加速 / 启动器 / 配置编辑 / 模组中心 / 存档管理全量落地（详见 [CHANGELOG](./CHANGELOG.md)）

[![Docs](https://img.shields.io/badge/docs-VitePress-646cff?logo=vite&logoColor=ffd62e)](https://hello-openttd.github.io?placeholder)
[![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)](#)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Tests](https://img.shields.io/badge/tests-59%20passed-brightgreen)](#)

</div>

---

## ✨ 特性

| 特性 | 说明 |
|------|------|
| 📦 多版本管理 | 官方 OpenTTD、JGRPP、CityMania Client（CMClient）以及其他 fork 版本 |
| ⚡ 镜像加速下载 | 自动选择最优镜像源（GitHub 官方源，镜像可自行添加），断点续传，SHA-256 校验 |
| 🔧 配置管理 | 独立/共享配置方案，`openttd.cfg` 图形化编辑器 |
| 🎨 模组管理 | 在线浏览下载 BaNaNaS 模组（NewGRF/AI/GameScript/音轨集），整合官方模组下载与管理 |
| 🚀 启动器 | 一键启动，参数构建，多实例运行，进程监控 |
| 🗺️ 存档管理 | 浏览、导入、导出、备份、恢复、搜索存档 |
| 🌐 国际化 | 中文（简体）和 English 支持，可切换 |
| 🎨 主题系统 | 浅色/深色主题切换 |
| 🛡️ 安全加固 | 路径遍历防护、URL 验证、文件校验、依赖审计 |

## 📚 文档

完整文档使用 VitePress 构建，中英双语，随仓库 `docs/` 目录维护，并通过 GitHub Actions 自动部署到 GitHub Pages：

| 文档 | 说明 |
|------|------|
| [用户指南（中文）](./docs/guide/introduction.md) | 安装、快速上手、各功能模块使用说明 |
| [开发文档（中文）](./docs/dev/overview.md) | 架构设计、功能规格、安全设计、测试与发布流程 |
| [English Docs](./docs/en/index.md) | English version of all documents |

```bash
# 本地预览文档站
cd docs
npm install
npm run dev
```

## 🛠️ 技术栈

- **框架**：Flutter（Desktop stable）+ Dart 3，首发 Windows / Linux / macOS
- **状态管理**：Riverpod · **路由**：go_router · **网络**：dio
- **国际化**：flutter_localizations + ARB（`zh-Hans` / `en`）
- **文档**：VitePress（GitHub Pages CI 部署）
- **协议**：AGPL-3.0

## 🚀 参与开发

请先阅读 [贡献指南](./CONTRIBUTING.md) 与 [开发文档](./docs/dev/overview.md)。

```bash
git clone https://github.com/Maicarons/hello-openttd.git
cd hello-openttd

# 文档站
cd docs && npm install && npm run dev

# 应用
flutter pub get
flutter analyze && flutter test
flutter run -d windows   # 或 linux / macos
flutter build windows --release
```

## 🗺️ 里程碑（详见 [ROADMAP](./ROADMAP.md)）

- **M0**：项目文档与规范（当前）→ **M1** 核心框架 → **M2** 版本管理与下载引擎 → **M3** 启动器 → **M4** 配置编辑器 → **M5** 模组中心 → **M6** 存档管理 → **M7** 发布打磨

## 📄 许可证与声明

本项目以 [GNU AGPL-3.0](./LICENSE) 协议开源。

**免责声明**：本项目是社区开发的第三方启动器，与 OpenTTD 官方团队、JGRPP、CityMania 及 BaNaNaS 无隶属关系。OpenTTD 为 OpenTTD 团队的商标/作品，相关版权归其作者所有。
