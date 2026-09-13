# Process & Launch Spec

`services/process/` translates user intent into an OpenTTD command line and owns the game process lifecycle.

## 1. Argument building

```dart
class LaunchOptions {
  final VersionManifest version;
  final LaunchMode mode;          // newGame | loadSave | joinServer | dedicated
  final String? savePath;
  final String? serverAddress;
  final String? resolution;
  final bool useSharedConfig;     // → -c <shared cfg>
  final List<String> extraArgs;   // appended verbatim, last
}
```

- Mode argument first, common args after, `extraArgs` last (highest priority).
- **Full command-line preview** (with working directory) before launching; copy button.
- Reference set (defer to `openttd --help`): `-g`, `-n host[:port]`, `-D`, `-c file`, `-r WxH`, `-d`, `-v/-s/-m`.

## 2. Spawning

```dart
final process = await Process.start(binaryPath, args,
  workingDirectory: versionDir,       // portable-mode critical
  mode: ProcessStartMode.normal);
```

- **Working directory = version directory** so portable config and relative resources resolve.
- **Modes**: `normal` (default; stdout/stderr → `logs/runs/<run-id>.log`, exit observable) or `detached` (setting; no streams). The launcher exiting does not kill already-running games (no job-object binding on Windows; orphaned processes on Unix).
- Unix: executable bit checked before start.

## 3. Run records & monitoring

```dart
class RunRecord {
  final String id;                 // uuid
  final String versionId;
  final LaunchOptions snapshot;
  final DateTime startedAt;
  final DateTime? exitedAt;
  final int? exitCode;
  final String logPath;
}
```

- `runs.json` keeps the last 200.
- **Multi-instance** allowed; shared-config concurrency warns about config races.
- UI: running cards with duration, live log tail, terminate button.
- **Terminate**: `process.kill()` then `sigkill` after 5 s.
- **Crash handling**: non-zero exits surface the last 30 log lines + "open log".

## 4. Races & edge cases

| Case | Handling |
|------|----------|
| Binary missing/moved | Pre-start existence check → guide to reinstall |
| Paths with spaces/Unicode | List-form arguments (no shell) — injection-proof |
| `extraArgs` injection | No shell interpretation; UI hint not to quote items |
| Uninstall while running | Blocked, asks to quit the game first |
| Config edit while running | Editor warns (see [parser §5](./cfg-parser#_5-concurrency-with-the-game)) |

## 5. Tests

- Full coverage of `buildArguments` (mode × common × extra).
- Fake executables (`.cmd`/`.sh` fixtures): clean exit, non-zero exit, kill, stdout capture.
