# 环境搭建

## 前置条件

### 通用

- **Flutter SDK**：stable 渠道（`flutter --version` ≥ 3.32 / Dart ≥ 3.8）。建议用 [fvm](https://fvm.app) 或版本管理工具固定团队版本。
- **IDE**：Android Studio / VS Code + Flutter 插件。
- **Node.js ≥ 20**：文档站开发（仅 `docs/` 需要）。

### 平台工具链

| 平台 | 要求 |
|------|------|
| Windows | Visual Studio 2022（含 **Desktop development with C++** 工作负载） |
| Linux | `clang cmake ninja-build pkg-config libgtk-3-dev`（Ubuntu/Debian 为例） |
| macOS | Xcode + Command Line Tools（`xcode-select --install`） |

### Windows 上构建 Linux/macOS 产物？

不行。各平台产物在对应平台的 CI runner 上构建（见[发布流程](./release)）；本地开发只需目标为当前平台的工具链。

## 克隆与验证

```bash
git clone https://github.com/hello-openttd/hello-openttd.git
cd hello-openttd

flutter doctor        # 确认目标平台前无 ✗（[!] 警告可接受）
flutter devices       # 应能看到 windows / linux / macos 桌面设备
```

## 运行（Flutter 工程落地后）

```bash
flutter pub get
flutter run -d windows    # 或 -d linux / -d macos
```

## 文档站

```bash
cd docs
npm install
npm run dev        # http://localhost:5173/hello-openttd/
npm run build      # 产物在 docs/.vitepress/dist
npm run preview    # 本地预览构建产物
```

> `base` 配置为 `/hello-openttd/`（与仓库名一致）。fork 后仓库名不同时，修改 `docs/.vitepress/config.mts` 中的 `base`，否则 Pages 部署后资源 404。

## 常见问题

| 症状 | 处理 |
|------|------|
| `flutter doctor` 报 Visual Studio 缺失 | 安装 VS2022 Community 并勾选 C++ 桌面开发负载 |
| Linux 构建报 `gtk/gtk.h not found` | `sudo apt install libgtk-3-dev ninja-build` |
| macOS 报签名错误 | `flutter config --enable-macos-desktop` 后重试；本地运行默认 Debug 自动签名 |
| 文档站 dev 端口冲突 | `npm run dev -- --port 5174` |
| 中国大陆网络下 Flutter/npm 慢 | 配置 `FLUTTER_STORAGE_BASE_URL` / `PUB_HOSTED_URL` 与 npm registry 镜像 |

## Git 工作流

1. 从 `main` 切分支：`feat/`、`fix/`、`docs/`、`refactor/`。
2. 提交信息遵循 Conventional Commits（见 [CONTRIBUTING](https://github.com/hello-openttd/hello-openttd/blob/main/CONTRIBUTING.md)）。
3. PR 前本地必须通过：`flutter analyze` 零告警 + `flutter test` 全绿 + 新页面 `docs` 双语同步。
