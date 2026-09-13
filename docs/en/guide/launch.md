# Launcher

The launch page is both the **argument builder** and the **process monitor**.

## Launch modes

| Mode | Argument | Notes |
|------|----------|-------|
| New game | `-g` | Random map |
| Load save | `-g <save>` | Jump into a `.sav` (recent saves quick-pick on Home) |
| Join server | `-n host[:port]` | Server list from OpenTTD's `servers.cfg` + favorites |
| Dedicated | `-D [host:port]` | Headless server |

Other options (collapsible panel on the launch page):

| Argument | Purpose |
|----------|---------|
| `-c <cfg>` | Config file (added automatically in shared mode) |
| `-r 1920x1080` | Window resolution |
| `-v` / `-s` / `-m` | Video / sound / music driver |
| `-d [level]` | Debug output |
| Custom | Any extra arguments, appended verbatim |

> The full set is whatever `openttd --help` prints; the launcher shows a **preview** of the final command line before launching.

## One-click launch

- **Home deck**: default version + recent saves.
- Options: minimize/exit the launcher after start (default: minimize), keep command line and logs on failure.

## Multi-instance

OpenTTD supports several processes at once; the launcher allows **multi-instance** by default:

- Each start creates a **run record** (time, version, exit code, log file).
- In shared-config mode, a second concurrent instance warns about config races (the game rewrites config on exit).
- Independent-config instances are safe to run in parallel.

## Process monitoring

Running instances appear at the bottom of the launch page:

- **State**: running / exited (with code) / failed to start
- **Live log**: stdout/stderr streamed to `logs/runs/<run-id>.log`, viewable inline
- **Terminate**: graceful first, force-kill after a grace period
- **Crash hints**: non-zero exits show the last 30 log lines and an "open log" shortcut
