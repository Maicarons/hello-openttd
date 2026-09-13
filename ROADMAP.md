# 路线图 / Roadmap

> v0.1.0 已交付 M1–M6 的核心路径（见 [CHANGELOG](./CHANGELOG.md)）；下列条目按实际完成状态滚动更新。

## M0 — 项目文档与规范 ✅（2026-09）

- [x] 完整开发文档（架构、功能规格、安全、测试、发布）
- [x] VitePress 双语文档站 + GitHub Pages CI
- [x] 社区文件（CONTRIBUTING / SECURITY / CoC）与工作流骨架
- [x] 参考研究：openttd-manager-plus 与 OpenTTD 源码（CDN manifest、BaNaNaS API、镜像教训）

## M1 — 核心框架 ✅（2026-09，随 v0.1.0）

- [x] Flutter 工程骨架：Riverpod + go_router + Material 3 布局（NavigationRail）
- [x] 设置体系（`settings.json`、数据根目录、便携模式检测）
- [x] 国际化（zh-Hans / en ARB + 运行时切换）与主题（浅色/深色/跟随系统）
- [x] 日志系统（滚动文件日志 + 诊断脱敏）
- [x] CI：`flutter analyze` + `flutter test`（三平台矩阵）

## M2 — 版本管理与下载引擎 ✅（2026-09，随 v0.1.0）

- [x] 版本源适配器（官方 CDN / GitHub Releases：JGRPP、CMClient；URL 列表源）
- [x] 下载引擎：镜像探测与自动选择、断点续传（Range）、SHA-256 校验（fail-closed）
- [x] 安装流水线：下载 → 校验 → magic-byte → 解压（Zip Slip 防护）→ 版本清单
- [x] 版本页：列表 / 安装 / 卸载 / 本地接管；独立与共享配置
- [ ] 夜间构建（nightlies）支持

## M3 — 启动器 ✅（2026-09，随 v0.1.0）

- [x] 四种启动方式 + 参数构建器（`-g` / `-n` / `-D` / `-c` / `-r` / `-p`）
- [x] 进程监控：运行记录、退出码、日志落盘、优雅终止、多实例
- [x] 首页启动台（统计卡片、版本选择、一键启动、最近运行）

## M4 — 配置管理 ✅（2026-09，随 v0.1.0）

- [x] 行保留式 `openttd.cfg` 解析器（保注释保顺序，畸形行无损往返）+ 自动备份
- [x] 图形化编辑器：类型化表单（内置键目录）+ 原始文本双视图
- [x] 独立/共享配置切换（共享经 `-c` 参数）
- [ ] `private.cfg` / `servers.cfg` 脱敏编辑界面

## M5 — 模组中心 ✅（2026-09，随 v0.1.0，范围见 ADR-012）

- [x] BaNaNaS 元数据 API 集成（浏览/搜索/详情/网页跳转 + 离线缓存）
- [x] 本地导入（`.tar` / `.grf`）、`content_download` 扫描与删除
- [ ] 自托管 mirror-server 桥接（服务端实现 TCP 协议后，启动器接入 `/bananas/{type}/{id}`）
- [ ] 依赖带入与兼容性提示（v2）

## M6 — 存档管理 ✅（2026-09，随 v0.1.0）

- [x] 存档浏览器（存档/自动存档/场景/高度图）、搜索/排序
- [x] 导入 / 导出 / 回收站式删除
- [x] 备份与恢复（zip + manifest + sha256 校验 + 恢复前安全副本）
- [ ] （v2）`.sav` 头部解析：游戏日期、版本、公司信息

## M7 — 发布打磨（进行中）

- [x] Windows 本地发布构建验证（30MB 便携 zip 基础）
- [ ] 三平台发布产物 CI（Windows zip / Linux tar.gz 与 AppImage / macOS zip）
- [ ] 自动更新检测（启动器检查自身新版本）
- [ ] 崩溃捕获与诊断包导出
- [ ] 代码签名评估（Windows Authenticode / macOS 公证）与安全审计
- [ ] v1.0.0 发布 🎉

## 更远期（Backlog）

- 共享 `content_download` / `save` 的链接化方案（Windows junction / Unix symlink）落地
- NewGRF 兼容性检测（基于游戏版本匹配）
- 启动器插件化版本源（动态脚本源）
- 更多语言（繁中、日语等，社区翻译流程）
