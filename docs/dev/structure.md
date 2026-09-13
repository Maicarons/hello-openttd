# 目录结构

## 仓库结构

```
hello-openttd/
├── .github/
│   ├── workflows/
│   │   ├── deploy-docs.yml      # VitePress → GitHub Pages
│   │   └── ci.yml               # Flutter analyze + test（三平台矩阵，路径过滤）
│   ├── ISSUE_TEMPLATE/          # Bug / Feature 表单
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── dependabot.yml           # actions + npm（pub 待工程落地启用）
├── docs/                        # VitePress 文档站（zh 根目录 + en/）
│   ├── .vitepress/
│   │   ├── config.mts           # 双语导航/侧边栏/base
│   │   └── (dist|cache)/        # 构建产物（gitignore）
│   ├── public/logo.svg
│   ├── index.md                 # 首页（中文）
│   ├── guide/                   # 用户指南（中文）
│   ├── dev/                     # 开发文档（中文）
│   ├── en/                      # English mirror
│   └── package.json
├── lib/                         # Flutter 应用代码（M1 落地）
├── test/                        # Flutter 测试
├── windows/ linux/ macos/       # 平台壳工程（flutter create 生成）
├── LICENSE                      # AGPL-3.0
├── CONTRIBUTING.md / SECURITY.md / CODE_OF_CONDUCT.md
├── ROADMAP.md / CHANGELOG.md
├── pubspec.yaml                 # M1 落地
└── analysis_options.yaml
```

## Flutter 代码结构（规划）

采用**分层 + 按功能分包**的混合结构：`core/data/services` 为技术分层，`features` 按页面域组织，服务实现单向依赖，UI 只经 Provider 访问服务。

```
lib/
├── main.dart                    # 入口：初始化日志/路径/设置，runApp
├── app.dart                     # MaterialApp.router：路由、i18n、主题装配
├── core/                        # 与业务无关的基础设施
│   ├── constants.dart
│   ├── paths/
│   │   ├── app_paths.dart       # 数据根目录解析（默认/便携模式）、子目录约定
│   │   └── fs_guard.dart        # 路径校验（normalize + within 断言，见安全设计）
│   ├── errors/
│   │   └── failures.dart        # sealed 失败类型（网络/校验/磁盘/路径/进程…）
│   ├── logging.dart             # 滚动文件日志
│   └── utils/                   # 日期、大小格式化、debounce 等
├── data/
│   ├── models/                  # 纯数据类 + JSON（手动 fromJson/toJson）
│   │   ├── version_manifest.dart
│   │   ├── version_source.dart
│   │   ├── mirror_config.dart
│   │   ├── launcher_settings.dart
│   │   ├── installed_content.dart
│   │   └── run_record.dart
│   └── repositories/            # JSON 文件读写（settings、manifests、mods、mirrors）
├── services/                    # 领域服务（无 UI 依赖，可独立单测）
│   ├── version_source/          # 版本源适配器（github_release / url_list）
│   ├── download/                # 下载引擎（镜像选择、Range 续传、SHA-256）
│   ├── archive/                 # 解压（zip-slip 防护、tar 代理）
│   ├── bananas/                 # BaNaNaS 客户端与缓存
│   ├── config/                  # openttd.cfg 解析/回写
│   ├── process/                 # 启动、参数构建、监控
│   ├── saves/                   # 存档扫描/备份
│   └── security/                # URL 校验、哈希
├── providers/                   # Riverpod 装配：服务 Provider、状态 Notifier
├── features/                    # 页面域
│   ├── home/                    # 启动台
│   ├── versions/                # 版本管理 + 安装向导
│   ├── launch/                  # 启动页 + 运行监控
│   ├── config_editor/           # 配置编辑器
│   ├── mods/                    # 模组中心
│   ├── saves/                   # 存档管理
│   └── settings/                # 设置
├── ui/
│   ├── theme/                   # Material 3 主题（浅/深）、品牌色
│   ├── widgets/                 # 通用组件（AsyncValue 视图、确认对话框…）
│   └── layout/app_shell.dart    # NavigationRail 骨架
└── l10n/
    ├── app_en.arb
    └── app_zh.arb               # gen-l10n 输出目录提交入库
```

## 依赖方向规则

```
features/ui → providers → services → data(core)
                                 ↘ core
```

- `core` 不依赖任何上层。
- `services` 之间允许引用接口（建议以抽象类 + Provider 注入），禁止循环。
- `ui/features` 禁止直接 `File`/`Process` 操作，一律走服务。

## 文件放置约定

| 内容 | 位置 |
|------|------|
| 新页面 | `features/<域>/pages/` + 路由注册于 `app.dart` |
| 新服务 | `services/<域>/` + 抽象接口 + Provider |
| 新 JSON 结构 | `data/models/` + `schemaVersion` 字段与迁移说明 |
| ARB 键 | 域名前缀，如 `versionsInstallTitle` |
| 测试 | 镜像 `lib/` 结构：`test/services/download/…` |
