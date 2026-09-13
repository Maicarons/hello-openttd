# 贡献指南 / Contributing Guide

感谢关注 hello-openttd！无论是文档、代码、翻译还是测试反馈，都非常欢迎。

> English summary at the bottom.

## 行为准则

参与本项目即表示你同意遵守 [行为准则](./CODE_OF_CONDUCT.md)。

## 如何贡献

### 1. 报告问题

- 使用 [Issue 模板](.github/ISSUE_TEMPLATE/bug_report.yml)，尽量附上启动器日志（设置 → 高级 → 打开日志目录）。
- 涉及下载/安装问题时，请附上**镜像名称**与**版本来源**（不要贴完整 Token）。

### 2. 提交代码

**环境搭建**见 [开发文档：环境搭建](./docs/dev/setup.md)。概要：

```bash
git clone https://github.com/<you>/hello-openttd.git
cd hello-openttd
flutter doctor          # Flutter stable, 三平台工具链见开发文档
flutter pub get
flutter analyze         # 必须零告警
flutter test            # 必须全部通过
```

**分支与提交约定**

- 分支名：`feat/xxx`、`fix/xxx`、`docs/xxx`、`refactor/xxx`
- 提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/)：
  - `feat(versions): 支持自定义版本源`
  - `fix(download): 修复断点续传偏移计算`
  - `docs(dev): 补充下载引擎规格`
- 每个 PR 保持单一主题，控制在可审阅的规模。

**PR 检查清单**（模板中已内置）

- [ ] `flutter analyze` 零告警，`flutter test` 通过
- [ ] 新增用户可见文案已同时加入 `app_zh.arb` 与 `app_en.arb`
- [ ] 涉及文件路径/网络请求的改动已遵循[安全设计](./docs/dev/security.md)（路径校验、URL 校验、校验和）
- [ ] 核心逻辑有单元测试
- [ ] 文档（`docs/`）同步更新

### 3. 翻译与文案

- 界面文案一律通过 ARB 文件，禁止硬编码字符串。
- 术语表见 [开发文档：国际化](./docs/dev/architecture.md#国际化与主题)。

### 4. 文档

`docs/` 为 VitePress 站点，`npm run dev` 本地预览。新增页面记得同时维护 `zh`（根目录）与 `en/` 两份，并在 `docs/.vitepress/config.mts` 的侧边栏注册。

## 安全问题

请勿在公开 Issue 中披露安全漏洞，按 [SECURITY.md](./SECURITY.md) 的流程私密报告。

## 许可

你提交的内容将以 **AGPL-3.0** 协议授权给本项目与所有使用者。

---

## English summary

- Bug reports: use the issue templates, attach launcher logs; never paste tokens.
- Code: Conventional Commits, one topic per PR, `flutter analyze` clean + `flutter test` green, all user-facing strings in both ARB files, security rules (path validation / URL validation / checksums) respected, docs updated in both `zh` and `en/`.
- Security vulnerabilities: report privately per [SECURITY.md](./SECURITY.md).
- Contributions are licensed under AGPL-3.0.
