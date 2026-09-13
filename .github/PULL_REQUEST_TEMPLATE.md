<!-- 标题格式：type(scope): 描述，如 feat(versions): 支持自定义版本源 -->

## 概述

<!-- 简述本次变更的动机与内容，关联 Issue：Fixes #123 -->

## 变更类型

- [ ] 功能（feat）
- [ ] 修复（fix）
- [ ] 文档（docs）
- [ ] 重构（refactor）
- [ ] 测试（test）
- [ ] 构建/CI（chore）

## 自查清单

- [ ] `flutter analyze` 零告警，`flutter test` 通过
- [ ] 新增用户可见文案已同时加入 `app_zh.arb` 与 `app_en.arb`
- [ ] 涉及文件路径的改动已做规范化 + 根目录约束校验（见 docs/dev/security.md）
- [ ] 涉及网络请求的改动已做 URL 校验，下载类改动有校验和验证
- [ ] 归档解压改动已防 Zip Slip / 符号链接逃逸
- [ ] 核心逻辑附带单元测试
- [ ] `docs/` 文档同步更新（中文 + English 两份）

## 截图（UI 变更时）

<!-- 浅色 / 深色主题各一张 -->
