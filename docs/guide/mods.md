# 模组中心

模组中心对接 OpenTTD 官方内容服务 **BaNaNaS**，在线浏览、下载并管理各类游戏内容。

## 支持的内容类型

| 类型 | 说明 | 安装位置 |
|------|------|----------|
| NewGRF | 新图形/车辆/产业等游戏内容 | `content_download/newgrf/` |
| AI | 电脑对手 | `content_download/ai/` |
| AI 库 | AI 依赖的公共库 | `content_download/ai/` |
| GameScript | 剧本逻辑 | `content_download/game/` |
| GS 库 | GameScript 依赖的公共库 | `content_download/game/` |
| 音轨集 / 基础集 | 音乐与图形/音效基础资源 | `content_download/baseset/` |
| 场景 | 预制地图 | `content_download/scenario/` |

## 浏览与安装

1. **模组中心 → 在线**，按类型筛选（NewGRF / AI / GameScript / 音轨集）或搜索（名称/作者/描述，本地过滤）。
2. 详情页包含：名称、作者、最新版本、文件大小、描述，以及**在浏览器打开**按钮。
3. **关于下载**：BaNaNaS 官方 API 不提供直接下载链接（内容只能通过游戏内 TCP 协议分发，CDN 地址不可猜测），因此推荐两种安装方式：
   - 点击 **打开网页** 在 bananas.openttd.org 查看该模组；
   - 启动游戏，用游戏内 **Content Download** 窗口下载——启动器会自动识别游戏下载的内容（已安装列表实时扫描 `content_download/` 目录）。
4. **本地导入**：把已有的 `.tar`（BaNaNaS 包）或 `.grf` 文件路径填入"导入本地文件"，复制到该版本对应目录。

**已安装列表**合并游戏内下载与启动器导入的内容，支持查看大小与删除。

## 兼容性提示

- NewGRF 与游戏版本（OpenTTD 主版本号、GRF 特性位）相关，装错版本可能导致花屏或崩溃。详情页会展示上游标注的兼容范围；**兼容性自动检测**在后续版本提供。
- JGRPP 增强特性的部分内容只在 JGRPP 下可用。
- 游戏内通过 **Content Download** 窗口安装的内容同样会出现在已安装列表（启动器扫描目录）；反之亦然，两者可以混用。

## 离线与缓存

内容列表缓存于 `cache/bananas/`（含 TTL），离线时可以浏览缓存并管理已安装模组，但不能下载新内容。

## 致谢

BaNaNaS 是 OpenTTD 社区的官方内容服务。请遵守各模组自身的许可证使用其作品；在服务器上使用 NewGRF 时，所有玩家会自动获得相同内容。
