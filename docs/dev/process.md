# 进程与启动规格

`services/process/` 负责把"用户意图"翻译成 OpenTTD 命令行，并管理游戏进程的生命周期。

## 1. 参数构建

```dart
class LaunchOptions {
  final VersionManifest version;
  final LaunchMode mode;          // newGame | loadSave | joinServer | dedicated
  final String? savePath;         // loadSave
  final String? serverAddress;    // joinServer / dedicated（host:port）
  final String? resolution;       // "1920x1080"
  final bool useSharedConfig;     // true → -c <shared cfg>
  final List<String> extraArgs;   // 用户自定义，原样附加
}

List<String> buildArguments(LaunchOptions o) => switch (o.mode) {
  LaunchMode.newGame   => ['-g', ..._common(o)],
  LaunchMode.loadSave  => ['-g', o.savePath!, ..._common(o)],
  LaunchMode.joinServer=> ['-n', o.serverAddress!, ..._common(o)],
  LaunchMode.dedicated => ['-D', if (o.serverAddress != null) o.serverAddress!, ..._common(o)],
};

List<String> _common(LaunchOptions o) => [
  if (o.useSharedConfig) ...['-c', o.sharedConfigPath],
  if (o.resolution != null) ...['-r', o.resolution!],
  ...o.extraArgs,
];
```

- 参数顺序：模式参数在前，公共参数在后；`extraArgs` 永远最后（用户优先级最高）。
- 启动前**预览完整命令行**（含工作目录），一键复制。
- 常用 OpenTTD 参数参考（以游戏 `--help` 为准）：`-g`（新游戏/载入）、`-n host[:port]`（联机）、`-D`（专用服务器）、`-c file`（配置）、`-r WxH`（分辨率）、`-d`（调试）、`-v/-s/-m`（视频/声音/音乐驱动）。

## 2. 启动

```dart
final process = await Process.start(
  binaryPath,
  args,
  workingDirectory: versionDir,        // 便携模式关键：cfg 就在 cwd
  mode: ProcessStartMode.normal,       // 监控模式
);
```

- **工作目录 = 版本目录**：保证 OpenTTD 便携配置、相对路径资源正确解析。
- **两种模式**：
  - `normal`（默认）：捕获 stdout/stderr → `logs/runs/<run-id>.log`；退出可感知。启动器退出**不影响**已启动游戏？→ Dart `Process` 不设 Job Object，父进程退出后子进程在三大平台均可继续运行（Unix 孤儿进程；Windows 无 job 绑定即不随之终止）。启动器退出前不主动杀游戏。
  - `detached`（设置项）：完全脱离，无日志流，适合"启动完就忘"。
- Unix 下启动前检查可执行位；Windows 下检查文件存在即可。

## 3. 运行记录与监控

```dart
class RunRecord {
  final String id;                 // uuid
  final String versionId;
  final LaunchOptions snapshot;    // 记录参数
  final DateTime startedAt;
  final DateTime? exitedAt;
  final int? exitCode;
  final String logPath;
}
```

- `runs.json` 滚动保留最近 200 条。
- **多实例**：直接允许多个 `Process` 并存；共享配置模式同时运行 >1 实例时，启动前警告配置互相覆盖风险。
- UI（启动页底部）：运行中卡片显示时长 + 查看日志（tail）+ 结束按钮。
- **结束进程**：`process.kill()`（SIGTERM / TerminateProcess），5s 未退出再 `ProcessSignal.sigkill`。
- **异常退出**：exit code ≠ 0 时 UI 展示日志尾部 30 行摘录与"打开日志"入口。

## 4. 竞态与边界

| 场景 | 处理 |
|------|------|
| 二进制被删/移动 | 启动前存在性检查，失败引导重装 |
| 版本目录含空格/Unicode | 参数以列表传递（不经 shell 拼接），天然免疫注入 |
| `extraArgs` 注入 | 同上，不做 shell 解释；UI 提示不要输入引号包裹项 |
| 游戏运行中卸载版本 | 禁止，提示先退出游戏 |
| 游戏运行中改配置 | cfg 编辑器保存前警告（见 cfg-parser §5） |

## 5. 测试要点

- `buildArguments` 纯函数全覆盖（模式 × 公共参数 × extra）。
- 进程服务用假可执行脚本（三平台各自的 `sh`/`cmd` 脚本 fixture）测：正常退出、非零退出、kill、stdout 捕获。
