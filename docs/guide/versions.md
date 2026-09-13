# 版本管理

版本管理页是启动器的核心：浏览、安装、更新与卸载各个 OpenTTD 版本。

## 内置版本源

| 版本源 | 内容 | 类型 | 校验 |
|--------|------|------|------|
| OpenTTD 官方 | 官方稳定版（CDN） | `cdn.openttd.org` 的 latest.yaml/manifest.yaml | **官方自带 SHA-256，全程校验** |
| JGRPP | JGR 的补丁版，带大量网络/游戏性增强 | GitHub Releases（`JGRennison/OpenTTD-patches`） | 记录哈希，标"未验证" |
| CMClient | CityMania 客户端 | GitHub Releases（`citymania-org/cmclient`） | 同上 |
| 自定义 | 任何 fork，可自行添加 | GitHub Releases 或 URL 列表 | 声明即强制 |

> 官方源优先走 OpenTTD CDN（无限额、自带校验和），比 GitHub API 更快更可靠。

## 安装一个版本

1. **版本管理 → 安装**，选择版本源与平台（通常自动匹配当前系统）。
2. 版本列表展示该源的全部发布（版本号、发布日期、资产大小）。
3. 选择版本 → 启动器自动解析对应平台的资产（如 `openttd-14.1-windows-win64.zip`）。
4. 选择**配置方案**（独立 / 共享，见下文）→ 开始下载。
5. 流程：**下载（断点续传）→ SHA-256 校验 → 解压（防 Zip Slip）→ 生成版本清单**。
6. 完成后版本出现在列表中，可直接启动。

安装失败时：

- 下载中断 → 可**继续下载**（已下载字节被保留）。
- 校验失败 → 安装立即终止并提示（fail-closed），可更换镜像重试。
- 解压/磁盘错误 → 查看日志（设置 → 高级 → 打开日志目录）。

## 更新与卸载

- **更新检测**：版本列表会对比最新发布，可一键升级（新目录安装，旧目录保留，确认后手动清理）。
- **卸载**：删除该版本目录；若有独立配置/存档，卸载前会询问是否同时清理或导出备份。

## 独立与共享配置

| | 独立配置（默认） | 共享配置 |
|---|---|---|
| `openttd.cfg` | 每版本一份（版本目录内） | 全局一份 |
| 存档 / 截图 / 模组 | 每版本独立 | 所有版本共用 |
| 新GRF 兼容性风险 | 低（改这个版本不影响那个版本） | 高（模组/配置变动影响所有版本） |
| 适合人群 | 多版本重度玩家 | 只玩一个版本、想集中管理存档 |

实现原理（也解释了文件放哪儿）：

- **独立配置**：OpenTTD 优先读取可执行文件同目录下的 `openttd.cfg`（便携模式）。启动器把配置写入版本目录即可实现隔离。
- **共享配置**：启动器通过 `-c <共享配置路径>` 参数让所有版本使用同一份配置；模组与存档目录通过 **目录链接**（Windows junction / Unix symlink）指到共享存储，无法建链的文件系统上退化为复制同步。

## 版本目录结构

```
<数据根目录>/
├── versions/
│   ├── official-14.1/
│   │   ├── openttd(.exe)              # 游戏可执行文件
│   │   ├── openttd.cfg                # 独立配置（独立模式）
│   │   ├── content_download/          # 模组（独立模式）或链接到共享
│   │   ├── save/                      # 存档（独立模式）或链接到共享
│   │   └── manifest.json              # 版本清单（启动器维护）
│   └── jgrpp-0.61.2/...
├── shared/                            # 共享配置模式下的数据
│   ├── config/openttd.cfg
│   ├── mods/{baseset,newgrf,ai,game,scenario}/
│   ├── saves/
│   └── backups/
├── cache/downloads/                   # 下载临时文件（断点续传）
├── mirrors.json                       # 自定义镜像
├── settings.json                      # 启动器设置
└── logs/
```

`manifest.json` 记录版本号、来源、平台、安装时间与校验和，是启动器识别版本的依据——请勿手动编辑。

## 自定义版本源

**设置 → 版本源 → 添加**，支持两种类型：

**1. GitHub Releases** — 填写 `owner/repo` 与各平台资产命名模板，`{version}` 为占位符：

```text
windows-x64: openttd-{version}-windows-win64.zip
linux-x64:   openttd-{version}-linux-generic-amd64.tar.xz
macos:       openttd-{version}-macos-universal.zip
```

**2. URL 列表** — 提供一个 JSON 文件地址（可托管在任意地方）：

```json
[
  { "version": "1.2.3", "date": "2026-01-20",
    "assets": {
      "windows-x64": { "url": "https://example.com/cmclient-1.2.3-win64.zip", "sha256": "…" },
      "linux-x64":   { "url": "https://example.com/cmclient-1.2.3-linux.tar.gz", "sha256": "…" }
    } }
]
```

> ⚠️ 自定义源的安全性由提供方决定：URL 必须为 HTTPS；带 `sha256` 的资产会被强制校验，不带校验和的资产安装时会有明确提示。
