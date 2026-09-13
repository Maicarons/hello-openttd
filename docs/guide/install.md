# 安装

OpenDepot 本身是绿色便携的桌面应用，无需安装器，解压即用。

## 系统要求

| 平台 | 要求 |
|------|------|
| Windows | Windows 10 1809+ (x64) |
| Linux | 主流发行版（需要 GTK3 运行库，如 `libgtk-3-0`） |
| macOS | macOS 12 Monterey+（universal：Intel + Apple Silicon） |

游戏本体（OpenTTD / JGRPP 等）**不需要预先安装**，由启动器负责下载。

## 获取启动器

从 GitHub Releases 下载对应平台的压缩包：

| 平台 | 产物 |
|------|------|
| Windows | `OpenDepot-<版本>-windows-x64.zip` |
| Linux | `OpenDepot-<版本>-linux-x64.tar.gz` / `.AppImage` |
| macOS | `OpenDepot-<版本>-macos-universal.zip` |

> Releases 页面同时提供 `sha256sums.txt` 校验文件，建议下载后核对（见[下载与镜像](./downloads#文件校验)）。

### Windows

1. 解压 zip 到任意目录（建议放在非系统盘，如 `D:\OpenDepot`）。
2. 运行 `opendepot.exe`。

### Linux

```bash
tar -xzf OpenDepot-*-linux-x64.tar.gz
cd OpenDepot
./opendepot
```

若使用 AppImage：`chmod +x OpenDepot-*.AppImage && ./OpenDepot-*.AppImage`

### macOS

1. 解压 zip，将 `OpenDepot.app` 拖入「应用程序」。
2. 首次启动若提示"无法验证开发者"（应用尚未签名公证）：右键点击 App → **打开**；或在终端执行：

```bash
xattr -cr /Applications/OpenDepot.app
```

## 首次启动

启动器首次运行会让你确认**数据根目录**（存放版本、存档备份、缓存等数据的位置）：

| 平台 | 默认数据根目录 |
|------|----------------|
| Windows | `%APPDATA%\OpenDepot` |
| Linux | `~/.local/share/opendepot`（遵循 XDG） |
| macOS | `~/Library/Application Support/OpenDepot` |

**便携模式**：在启动器程序所在目录放置名为 `OpenDepotData` 的文件夹（或空标记文件 `portable.flag`），启动器将使用该目录作为数据根目录，适合放在 U 盘或同步盘中。

数据根目录之后可在 [设置](./settings#数据根目录) 中迁移。

## 升级与卸载

- **升级启动器**：下载新版本压缩包覆盖程序文件即可；数据根目录与版本数据不受影响。
- **卸载**：直接删除程序目录；如需清空全部数据（含已装版本），删除数据根目录。

## 常见安装问题

- Windows 提示缺少运行库 / SmartScreen 拦截 → 见 [FAQ](./faq#windows-相关)。
- Linux 启动报 GTK 相关错误 → 安装 `libgtk-3-0` 等依赖，见 [FAQ](./faq#linux-相关)。
- macOS Gatekeeper 阻止启动 → 见上文 macOS 步骤与 [FAQ](./faq#macos-相关)。
