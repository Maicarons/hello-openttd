# 开发总览与决策记录

本文是开发文档的入口：项目目标、范围、非目标、关键工程决策（ADR）与文档地图。

## 项目定位

OpenDepot（仓库 `hello-openttd`）是 Flutter 桌面端 OpenTTD 启动器，对标 Minecraft 生态的 HMCL / PCL2 体验，首发 Windows / Linux / macOS。

**范围（In scope）**

- OpenTTD 及其 fork 的下载、安装、更新、卸载
- 启动参数构建与进程管理
- `openttd.cfg` 等配置文件的查看与编辑
- BaNaNaS 内容的浏览/下载/管理
- 存档的浏览/导入导出/备份恢复
- 启动器自身的国际化、主题、设置

**非目标（Out of scope）**

- 修改、分发或篡改游戏本体内容
- 服务器列表服务/联机中转等需要后端的功能（全部功能本地完成）
- 移动端 / Web（架构上不强求，但不做适配承诺）
- OpenTTD 本体的 Bug 修复（上游问题引导至官方仓库）

## 里程碑与文档映射

| 里程碑 | 内容 | 相关规格文档 |
|--------|------|--------------|
| M1 核心框架 | 工程骨架、设置、i18n、主题、日志 | [架构设计](./architecture)、[目录结构](./structure) |
| M2 版本与下载 | 版本源、下载引擎、安装向导 | [下载引擎](./download-engine) |
| M3 启动器 | 参数构建、进程监控、启动台 | [进程与启动](./process) |
| M4 配置管理 | 解析器、编辑器 | [配置解析器](./cfg-parser) |
| M5 模组中心 | BaNaNaS 客户端、安装管理 | [BaNaNaS 集成](./bananas) |
| M6 存档管理 | 浏览、备份恢复 | [存档服务](./saves) |
| M7 发布 | 三平台产物、更新检测 | [发布流程](./release) |

## 架构决策记录（ADR）

采用轻量 ADR：决策进入下表；需要详细论述时在 `docs/adr/` 新增编号文档。改动决策时在表中追加"修订"行，不删除历史。

| # | 决策 | 状态 | 理由摘要 |
|---|------|------|----------|
| ADR-001 | 桌面端 Flutter，首发 Windows/Linux/macOS | 已接受 | 单代码库三平台；Dart 生态满足 HTTP/归档/进程需求；UI 迭代快 |
| ADR-002 | 状态管理使用 Riverpod（不使用代码生成，手写 Provider） | 已接受 | 编译期安全、可测试；避免 build_runner 依赖链 |
| ADR-003 | 路由使用 go_router | 已接受 | 声明式路由 + 深层导航简单可靠 |
| ADR-004 | 独立配置依赖 OpenTTD 便携模式（cfg 与二进制同目录）；共享配置用 `-c` 参数 + 目录链接 | 已接受 | 利用游戏原生行为，零侵入 |
| ADR-005 | zip 用纯 Dart `archive` 包；`.tar.xz` 在 Linux 上调用系统 `tar`（macOS/Windows 资产优先 zip） | 已接受 | 避免引入原生 xz 绑定；系统 tar 在 Linux 普遍可用 |
| ADR-006 | 镜像采用 URL 模板改写（`{url}` 前缀型 + 路径改写型），只影响文件下载，API 直连 | 已接受 | 模板足够通用；API 改写易出错且涉及鉴权 |
| ADR-007 | HTTP 客户端使用 dio | 已接受 | 拦截器（镜像改写、重试）、Range 断点续传支持成熟 |
| ADR-008 | 设置用 JSON 文件（`settings.json`）而非 shared_preferences 单独存储 | 已接受 | 便于备份/迁移/便携模式；结构化数据（镜像、版本源）也需文件化 |
| ADR-009 | 校验和信任模型：fail-closed，已知发布哈希优先，无哈希资产明确标注"未验证" | 已接受 | 见[安全设计](./security) |
| ADR-010 | 文档站 VitePress 双语（根目录中文 + `/en/`），GitHub Pages 部署 | 已接受 | 用户要求；双语维护成本可控 |
| ADR-011 | 官方版本源走 OpenTTD CDN（latest.yaml/manifest.yaml，自带 sha256sum），GitHub API 仅用于 JGRPP/CMClient/自定义源 | 已接受 | 无限额且全程可校验；借鉴 openttd-manager-plus 调研结论 |
| ADR-012 | BaNaNaS v1 只做浏览/检索/网页跳转/本地导入，不做字节下载（官方 API 不暴露下载链接） | 已接受 | 内容仅能走游戏内 TCP 协议；自托管 mirror-server 桥接列为 v2 |
| ADR-013 | 默认镜像仅内置 direct + ghfast.net；下载前做归档 magic-byte 校验 | 已接受 | ghproxy.com 域名易主后返回 200 HTML 静默损坏下载的教训 |

## 技术栈基线

| 层 | 选型 |
|----|------|
| SDK | Flutter stable（≥ 3.32）/ Dart 3 |
| 状态 | flutter_riverpod |
| 路由 | go_router |
| 网络 | dio |
| 归档 | archive（zip）；系统 tar（.tar.xz，Linux） |
| 校验 | crypto（SHA-256） |
| 路径/平台 | path, path_provider |
| i18n | flutter_localizations + intl（ARB） |
| 存储 | 本地 JSON 文件（settings.json / manifest / mods） |
| 日志 | logger + 滚动文件输出 |
| 窗口 | window_manager（标题/尺寸/深色标题栏） |
| 测试 | flutter_test + mocktail + shelf 测试服务器 |

## 工程约定

- **语言**：代码、注释、标识符一律英文；用户可见文案一律走 ARB（zh + en 同步）。
- **分析**：`flutter analyze --fatal-infos` 零告警为合并门槛。
- **提交**：Conventional Commits；PR 模板含安全自查项。
- **依赖**：能少则少；新依赖需在 PR 中说明理由与替代方案；锁文件提交。

## 文档地图

```
docs/
├── guide/  用户指南（安装、各功能页、FAQ）
└── dev/    开发文档
    ├── overview        本文（总览与 ADR）
    ├── setup           环境搭建
    ├── structure       仓库与代码目录结构
    ├── architecture    架构设计（分层、状态、错误处理、i18n/主题）
    ├── download-engine 下载引擎规格（镜像/续传/校验）
    ├── bananas         BaNaNaS 集成规格
    ├── cfg-parser      配置解析器规格
    ├── process         进程与启动规格
    ├── saves           存档服务规格
    ├── security        安全设计与威胁模型
    ├── testing         测试策略
    └── release         版本发布流程
```
