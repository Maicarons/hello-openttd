# BaNaNaS 集成规格

`services/bananas/` 提供 BaNaNaS（OpenTTD 官方内容服务）的浏览、检索与本地内容管理。

## 1. 上游事实（已对照 openttd-manager-plus 与 bananas-api 确认）

- **元数据 API**：`https://bananas-api.openttd.org/package/{type}`（列表）、`/package/{type}/{unique-id}`（详情）；type 取值 `newgrf / ai / game-script / base-music` 等。
- **关键限制**：API **不提供直接下载链接**。BaNaNaS 内容只通过游戏内的自定义 TCP 协议分发，CDN 地址按 md5-partial 设计为不可猜测。
- 因此启动器 v1 的模组能力为：**浏览 / 搜索 / 详情 / 网页跳转（bananas.openttd.org）/ 本地导入 / 已安装管理**；字节级下载交给游戏内 Content Download 窗口。
- 远期方案：自托管 mirror-server（参考 openttd-manager-plus 的实现，服务端实现 TCP 协议并暴露 `/bananas/{type}/{id}` HTTP 端点），启动器将其作为可选内容源接入（v2）。

## 2. 抽象接口

```dart
class BananasService {
  Future<List<BananasPackage>> browse(String type, {bool forceRefresh});  // API + 磁盘缓存
  String webPageUrl(String type, String uniqueId);                        // 跳转 bananas.openttd.org
  List<InstalledContentFile> scanInstalled(String gameDir);               // 扫描 content_download
  String importLocal(String gameDir, String sourceFile);                  // .tar/.grf 导入
  void deleteInstalled(String gameDir, String relativePath);              // 精确删除
}
```

- 列表缓存于 `cache/bananas/{type}.json`（TTL 6h）；离线时回退旧缓存并提示。
- 搜索在本地对名称/作者/描述做子串过滤（API 无服务端搜索）。

## 3. 安装布局

BaNaNaS 包（`.tar`）按 OpenTTD 的搜索路径放入版本目录的 `content_download/` 树（与游戏源码 `fileio.cpp` 的子目录定义一致，库内容进 `library/` 子目录）：

| 内容 | 目标子目录 |
|------|------------|
| NewGRF | `content_download/newgrf/` |
| AI | `content_download/ai/` |
| AI 库 | `content_download/ai/library/` |
| GameScript | `content_download/game/` |
| GS 库 | `content_download/game/library/` |
| 基础集（图形/音效/音乐） | `content_download/baseset/` |
| 场景 | `content_download/scenario/` |

本地导入与已安装扫描遵循同一布局；登记文件为 `mods.json`（schemaVersion + items[]）。

## 4. 已安装扫描

模组中心"已安装"页合并两个来源：

1. `mods.json`（启动器安装/导入的）
2. **目录扫描** `content_download/*`（游戏内置 Content Download 窗口装的）

扫描结果以文件级去重展示；游戏装的条目标记来源为 `game`，只提供删除（提供说明：删除会影响游戏内列表）。

## 5. 本地导入

- 接受 `.tar`（BaNaNaS 标准包：解包后按内部结构放对应目录）与裸 `.grf`（放 `newgrf/`）。
- 导入即登记 `mods.json`（`source: "local"`，md5 本地计算）。
- 拖拽（desktop drop）与文件选择器两种入口。

## 6. 依赖与兼容性（v2 预留）

- BaNaNaS 元数据含依赖（AI/GS 库）与兼容版本范围：v1 仅展示；v2 安装时自动带入依赖并提示不兼容。
- NewGRF 与 OpenTTD 主版本兼容性自动检测预留 `CompatibilityChecker` 接口。

## 7. 错误场景

| 场景 | 行为 |
|------|------|
| API 不可达 | 提示离线，展示缓存列表 |
| 下载中断 | 下载引擎断点续传 |
| 内容 md5 校验失败 | fail-closed，删除分片 |
| 安装目标不可写 | 提示目录权限问题，不落半截文件（先解压到临时目录再原子移动） |

## 8. 法律与礼貌

- 内容版权归各自作者；详情页展示上游许可证。
- 遵守上游 API 礼貌性约束：请求频率限制、UA 标识（`hello-openttd/<version>`）、列表缓存减轻服务端压力。
