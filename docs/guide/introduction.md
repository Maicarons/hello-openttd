# 简介

**OpenDepot**（工作代号）是一个开源的桌面级 **OpenTTD 启动器**，灵感来自 Minecraft 生态中成熟的 HMCL / PCL2 启动器：让"装一个版本、配一个模组、开一局游戏"变成点几下鼠标的事，而不是解压压缩包、翻论坛、手动改配置文件。

> 🚧 项目当前处于**文档与架构设计阶段**，功能将按 [路线图](https://github.com/hello-openttd/hello-openttd/blob/main/ROADMAP.md) 逐步交付。

## 为什么需要启动器？

手动管理 OpenTTD 的典型痛点：

| 痛点 | OpenDepot 的解法 |
|------|------------------|
| 想同时玩官方版和 JGRPP，需要手动下载、解压到不同目录 | 多版本管理，各版本独立目录，一键切换 |
| GitHub 下载慢或不可达 | 内置镜像加速（自动选优、断点续传、校验） |
| 两个版本共用配置，改了这边坏那边 | 独立/共享配置方案，可选 |
| 装 NewGRF/AI 要去 BaNaNaS 网站下载再放进目录 | 内置模组中心，在线浏览安装 |
| `openttd.cfg` 全是英文键名，改错就崩 | 图形化编辑器，带类型与取值范围提示 |
| 存档散落各处，备份全靠手动复制 | 存档浏览器 + 一键备份/恢复 |

## 核心特性

- **📦 多版本管理** — 官方 OpenTTD、[JGRPP](https://github.com/JGRennison/OpenTTD-patches)、CityMania Client（CMClient）及其他 fork；支持自定义版本源。
- **⚡ 镜像加速下载** — 自动探测最优下载源（GitHub 官方源为默认，镜像可自行添加），断点续传，SHA-256 校验。
- **🔧 配置管理** — 独立/共享配置方案；`openttd.cfg` 图形化编辑器。
- **🎨 模组管理** — 在线浏览下载 BaNaNaS 内容（NewGRF / AI / GameScript / 音轨集 / 场景），统一管理本地模组。
- **🚀 启动器** — 一键启动、启动参数构建、多实例、进程监控。
- **🗺️ 存档管理** — 浏览、导入导出、备份恢复、搜索。
- **🌐 国际化** — 简体中文 / English。
- **🎨 主题系统** — 浅色 / 深色 / 跟随系统。
- **🛡️ 安全加固** — 路径遍历防护、URL 校验、文件校验、依赖审计（详见[安全设计](/dev/security)）。

## 平台支持

| 平台 | 状态 |
|------|------|
| Windows 10/11 (x64) | ✅ 首发 |
| Linux (x64, AppImage/tar.gz) | ✅ 首发 |
| macOS 12+ (universal) | ✅ 首发 |

## 术语表

| 术语 | 含义 |
|------|------|
| 版本（Version） | 一份已安装的 OpenTTD 游戏副本，可以是官方版或某个 fork |
| 版本源（Source） | 提供版本下载的渠道，如 GitHub Releases 或自定义 URL 列表 |
| 镜像（Mirror） | 加速 GitHub 资源下载的中转服务 |
| 独立配置 | 每个版本使用自己的 `openttd.cfg` 与数据目录 |
| 共享配置 | 所有版本共用一份配置与数据目录 |
| 内容（Content） | BaNaNaS 上的可下载物：NewGRF、AI、GameScript、音轨集、场景等 |

## 与 OpenTTD 的关系

OpenDepot 是**社区开发的第三方启动器**，与 OpenTTD 官方团队无隶属关系。它不修改游戏本体，仅负责下载、配置与启动。OpenTTD 本身的 Bug 请前往 [OpenTTD 官方仓库](https://github.com/OpenTTD/OpenTTD) 反馈。

## 下一步

- [安装 OpenDepot](./install)
- [快速上手：5 分钟开一局](./quick-start)
