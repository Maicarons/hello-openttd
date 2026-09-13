# 更新日志 / Changelog

本项目的所有显著变更都会记录在本文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [0.1.0] — 2026-09-14

首个可运行版本（Windows 优先，Linux/macOS 代码就绪待 CI 产物）。

### Added

- **版本管理**：官方 OpenTTD（CDN，自带 SHA-256 全程校验）、JGRPP、CMClient 三个内置版本源；自定义 GitHub / URL 列表源；安装 / 卸载 / 本地版本接管（adopt）
- **下载引擎**：镜像自动探测与选择（默认 direct + ghfast.net）、HTTP Range 断点续传、流式 SHA-256 校验（fail-closed）、逐镜像回退、magic-byte 归档校验、Zip Slip 防护
- **启动器**：四种启动方式（新游戏/载入存档/加入服务器/专用服务器）、命令行预览、多实例、进程监控（运行记录、日志落盘、优雅终止）、独立/共享配置（`-c`）
- **配置编辑器**：行保留式 `openttd.cfg` 解析器（保注释保顺序、畸形行无损往返）、类型化表单（内置键目录）+ 原始文本双视图、自动 `.bak` 备份（保留 10 份）
- **模组中心**：BaNaNaS 在线浏览/搜索/详情/网页跳转（官方 API 不提供直接下载，见文档）、本地导入（.tar/.grf）、`content_download` 已安装扫描与删除
- **存档管理**：扫描（存档/自动存档/场景/高度图）、搜索、导入/导出、回收站式删除、zip 备份与校验恢复（安全副本机制）
- **设置**：双语（zh-Hans/en，运行时切换）、浅色/深色/跟随系统主题、镜像管理、GitHub PAT（日志脱敏）
- **安全基线**：`fs_guard` 路径守卫（唯一入口）、URL 校验（HTTPS-only、防 SSRF、防降级）、参数列表式传递（无 shell）、JSON 原子写入
- **工程**：59 个单元/集成测试全绿（本地 HTTP 服务器模拟 Range/206、CDN/GitHub/URL 源 fixture）、GitHub Actions（三平台 analyze+test 矩阵、VitePress Pages 部署）

[0.1.0]: https://github.com/hello-openttd/hello-openttd/releases/tag/v0.1.0

## [Unreleased]（历史规划存档）

### Added（规划中）

- 项目文档体系：双语文档站（VitePress / GitHub Pages）、架构与功能规格、安全与测试策略
- 社区与工程基础设施：CONTRIBUTING / SECURITY / CoC、GitHub Pages 部署工作流、Flutter CI、Issue/PR 模板、Dependabot
- 规划里程碑见 [ROADMAP.md](./ROADMAP.md)：M1 核心框架 → M7 v1.0 发布

[Unreleased]: https://github.com/hello-openttd/hello-openttd/compare/v0.1.0...HEAD
