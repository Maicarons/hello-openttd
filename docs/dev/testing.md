# 测试策略

## 原则

- **核心逻辑零网络零 UI 即可测试**：服务层全部依赖注入（HTTP、文件系统根目录、时钟）。
- 合并门槛：`flutter analyze --fatal-infos` 零告警 + `flutter test` 全绿 + 新增核心逻辑有测试。
- 覆盖率目标：`lib/services` 与 `lib/data` ≥ 70%（CI 报告，未强制门槛，持续逼近）。

## 分层测试

| 层 | 类型 | 覆盖内容 |
|----|------|----------|
| `core/paths` | 单元 | 文件名校验、`safeJoin` 逃逸用例（fuzz） |
| `services/download` | 单元 + 集成 | Range 续传、镜像选择、校验失败、重试退避 |
| `services/version_source` | 单元 | GitHub API 响应解析（fixture）、资产模板匹配 |
| `services/bananas` | 单元 | 类型映射、目录布局、mods.json 往返 |
| `services/config` | 单元 | 行保留往返（golden）、编辑 diff、畸形输入 |
| `services/process` | 单元 | 参数构建（纯函数）+ 假进程生命周期 |
| `services/saves` | 单元 + 性能 | 扫描、备份往返、文件名 fuzz、万文件基准 |
| `data/repositories` | 单元 | JSON schema 迁移（v1→v2） |
| UI | Widget（少量） | 主题切换、语言切换、AsyncValue 错误视图 |
| 全流程 | 手动清单 | 每次发布执行（见[发布流程](./release)） |

## 测试基建

**本地 HTTP 服务器**：`package:shelf` 起测试服务器，真实模拟：

- `206 Partial Content` / `Content-Range`（断点续传）
- ETag 变化（续传失效路径）
- 慢响应 / 断连（重试与超时）
- `sha256sums.txt`（校验通过/失败）

**Fixture 约定**：

- 小型 zip / tar.gz / cfg 样例放在 `test/fixtures/`（均 < 100KB）。
- GitHub/BaNaNaS API 响应录制为 JSON fixture，标注抓取日期。
- 假游戏可执行：Windows `.cmd` / Unix `.sh` 脚本，可编排"输出日志后退出码 N"。

**时间与随机**：注入 `Clock` 抽象与固定 seed，禁止测试内 `DateTime.now()` 直调。

## 运行

```bash
flutter test                                  # 全部
flutter test test/services/download/          # 单目录
flutter test --coverage                       # 覆盖率（CI 上传 lcov）
flutter test --update-goldens                 # 更新 golden（仅本地，随 PR 提交）
```

## 手动验收清单（发布前）

1. 全新安装：三平台首次启动 → 数据根目录确认 → 安装官方版 → 启动 → 开局
2. 断点续传：下载中断网/取消 → 恢复下载继续
3. 镜像回退：把镜像指向死地址 → 自动回退官方源
4. 校验失败：篡改 fixture → 明确报错且不产生半成品目录
5. 独立/共享配置：两版本分别启动，配置/存档按预期隔离或共享
6. 配置编辑器：改 `autosave` → 游戏内确认生效；保存备份存在
7. 模组：BaNaNaS 安装 → 游戏内启用；卸载后游戏内消失
8. 存档：备份 → 删档 → 恢复成功
9. i18n/主题：双语言、双主题全页面过一遍无溢出/未翻译键
10. 多实例：两实例同时运行互不干扰（独立配置）
