# 配置解析器规格

`services/config/` 负责解析、编辑与回写 OpenTTD 配置文件（`openttd.cfg` 为主，`private.cfg`、`servers.cfg` 识别但不公开编辑）。

## 1. 文件格式认知

`openttd.cfg` 为 INI 风格：

```ini
[misc]
language = filename
autosave_on_exit = true
currency = CNY

[gui]
autosave = 12

[music]
custom_1 = ...      ; 注释
```

事实要点：

- 分区 `[name]`，键值 `key = value`；布尔 `true/false`；数值可为 int 或带枚举语义。
- 游戏自己会**重写整个文件**（键顺序、注释策略由游戏决定）——因此启动器的编辑价值在"保结构"，冲突窗口见 §5。
- 除主配置外还有：`private.cfg`（客户端昵称/密码等敏感项）、`servers.cfg`（已知服务器列表）。

## 2. 行保留式解析（核心决策）

启动器**不整文件重建**，而是解析为带行号的模型，编辑时只改动目标行，最大限度保留注释、空行与键顺序（避免游戏/用户的手工注释丢失）：

```dart
class CfgDocument {
  final List<CfgLine> lines;          // 原始行（含注释/空行）
  final Map<String, CfgSection> sections;  // name → 键 → 行引用
}

sealed class CfgLine {
  CommentLine / BlankLine / SectionLine / KeyValueLine / UnknownLine
}
```

- 解析容错：无法理解的行保留为 `UnknownLine`，回写原样输出（**永不丢弃用户文件内容**）。
- 编码：UTF-8 读写；BOM 保留。

## 3. 键目录（Key Catalog）

类型化表单的数据源，内置 YAML/JSON 目录（随启动器分发，版本化维护）：

```yaml
- section: gui
  key: autosave
  type: enum            # bool | int | string | enum | path
  options: [off, "3", "6", "12"]   # 按 OpenTTD 语义为月份间隔
  labels: { zh: 自动保存间隔, en: Autosave interval }
  docs:
    zh: 以游戏内月为单位的自动保存间隔
    en: Interval between autosaves, in game months
- section: network
  key: client_name
  type: string
  sensitive: false
```

- 覆盖**常用键**即可，不追求全集；未收录键在原始视图编辑（见下）。
- JGRPP 等扩展键：目录按 `flavors: [vanilla, jgrpp]` 标注，编辑器按版本源显示对应提示。

## 4. 编辑与校验

- **表单视图**：按目录渲染控件；`bool`→开关、`enum`→下拉、`int`→数字框（min/max 来自目录）、`string`→文本。
- **原始视图**：`CfgDocument` 的文本编辑器；两者共享同一文档模型实时同步。
- 保存前校验：类型、范围、非法字符（值内换行、控制字符拒绝）；失败列出问题行，禁止保存。
- **自动备份**：保存前写 `openttd.cfg.bak-YYYYMMDDHHmmss`，保留最近 10 份。

## 5. 与游戏的并发约定

游戏退出时会整体重写配置文件，可能覆盖启动器已做的编辑。策略：

1. 保存前检测游戏进程是否在运行（同一版本目录）→ 运行中则警告"建议退出游戏后再保存"。
2. 保存时记录文件 mtime；若 mtime 与加载时不一致（游戏改过）→ 提示重新加载。

## 6. 敏感文件处理

- `private.cfg` 中的键（`client_name`、`server_password`、`join_server_password` 等）在编辑器中**脱敏**（显示 `••••`），复制/导出时默认过滤。
- `servers.cfg` 只读展示（服务器列表），不提供编辑（游戏内管理更安全）。

## 7. 测试要点

- 往返测试：解析 → 不改动 → 回写，文件**逐字节相同**（golden 文件）。
- 编辑测试：改 1 个键 → 回写 diff 仅含目标行。
- 畸形文件测试：空文件、无分区头、重复分区、重复键、超长行——全部可解析且回写无损。
- 键目录完备性测试：目录中每个键类型合法、labels 双语齐全（CI 校验）。
