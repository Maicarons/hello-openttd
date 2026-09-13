# Downloads & Mirrors

Every download (versions, mods) flows through one engine: **best-source selection, resumable transfers, SHA-256 verification**.

## How it works

1. **Candidate list**: GitHub official source + your enabled mirrors.
2. **Probing**: light-weight probe (latency + small-sample throughput, cached ~10 min).
3. **Selection**: the fastest available source wins by default; failures fall back automatically.
4. **Verification**: SHA-256 must pass before anything is extracted or installed.

## Mirror strategies

**Settings → Downloads & Mirrors**:

| Strategy | Behavior |
|----------|----------|
| Auto (default) | Probe per download, auto-fallback to official |
| Fastest | Always use the most recent probe winner |
| Fixed mirror | Always the chosen mirror, fallback on failure |
| Official only | Never touch mirrors |

## Adding a custom mirror

**Settings → Downloads & Mirrors → Add mirror**: a name plus a URL template using `{url}`. Prefix-style GitHub accelerators use:

```text
https://ghproxy.example.com/{url}
```

Rewrite-style templates are also supported:

```text
https://mirror.example.com/github/{owner}/{repo}/releases/download/{tag}/{asset}
```

Notes:

- **HTTPS-only** mirrors; the substituted URL is re-validated after templating.
- Mirrors affect **file downloads only**; the GitHub API (release lists) goes direct to `api.github.com` (a separate API proxy can be configured in settings).
- Third-party mirrors come and go — keep the official source as fallback.
- Unauthenticated GitHub API is limited to 60 req/h; a personal access token (stored locally) raises it.

## Resumable downloads

- Progress persists in `cache/downloads/` (`.part` data + `.meta` metadata).
- Interruptions (network, app exit) resume from the last byte.
- If the remote file changes (ETag/length mismatch), partial data is discarded and the download restarts — this prevents corrupted assemblies.

## File verification

| Asset | Verification |
|-------|--------------|
| Known releases of built-in sources | Pinned SHA-256 from the source registry / publisher |
| Custom-source assets with `sha256` | Enforced |
| Assets without checksums | Hash computed after download and recorded in the manifest; UI labels it **"unverified"** |
| Launcher releases | `sha256sums.txt` attached to each Release |

Verification failures are always **fail-closed**: nothing is installed or run, logs are kept.

## Privacy

The launcher ships **no telemetry**. Network access happens only when you trigger downloads/refreshes; diagnostics stay in local logs.
