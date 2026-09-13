# Security Design

The launcher has three high-privilege capabilities — writing disk, network access, spawning processes. The design constrains all three; these rules are **merge gates** enforced via the PR checklist.

## 1. Threat model (STRIDE-lite)

| Threat | Scenario | Mitigation |
|--------|----------|------------|
| Path traversal | Malicious names escaping expected dirs | Central `fs_guard` |
| Download hijack | Mirror serving malware | HTTPS-only + SHA-256 fail-closed + official fallback |
| Zip slip / link escape | `../`, absolute paths, symlinks in archives | Per-entry extraction checks |
| Argument injection | Special chars in names/args | List-form args, no shell |
| SSRF | Custom mirrors pointing intranet-ward | URL validation policy |
| Supply chain | Poisoned dependencies | Lockfiles + Dependabot + minimal dependency surface |
| Credential leakage | Tokens in logs | Log redaction filter |

## 2. Path safety (`core/paths/fs_guard.dart`)

**Single entry point** for every "user string → filesystem path" construction:

```dart
/// Validates name as a single path component and returns the normalized
/// path under root. Throws PathGuardFailure otherwise.
Path safeJoin(Path root, String name);
```

Rules:

1. Filename allow-list: `A-Za-z0-9._ -` plus Unicode letters; length 1–128; reject separators (`/`, `\`, `:`), NUL, and Windows reserved names (`CON`, `PRN`, `AUX`, `NUL`, `COM1-9`, `LPT1-9`).
2. After `normalize()`, require `isWithin(root)`; `resolveSymbolicLinksSync()` re-checked before writes.
3. Internal ids stricter: `^[a-z0-9][a-z0-9._-]{0,63}$`.

## 3. Archive extraction

- **zip**: reject absolute paths and `..` components; total uncompressed cap (4× archive size, ≤ 2 GB — zip-bomb guard); ≤ 50000 entries; symlinks dropped and logged.
- **tar** (system tar): `--no-same-owner` on Unix; extract into an empty dedicated dir; post-verify every file `isWithin(target)` — on failure wipe the dir and error.
- Check free space before extracting.

## 4. URL validation

For **every** outbound URL (sources, rewritten mirrors, BaNaNaS, update checks):

1. `https` only (dev builds may allow `http://127.0.0.1`).
2. No userinfo; no IP-literal hosts (SSRF surface); hostnames must contain a dot (same exception as above).
3. Redirects: `maxRedirects ≤ 5`, **re-validated per hop**; `https → http` downgrade always rejected.
4. Mirror templates: substituted URLs fully re-validated.
5. 2 GB content cap; `Content-Type` recorded but not trusted.

## 5. Trust model

| Tier | Meaning |
|------|---------|
| Tier 1 pinned | Built-in source registry pins SHA-256 for known releases |
| Tier 2 declared | Custom-source `sha256` enforced |
| Tier 3 recorded | No hash available → compute, record in manifest, UI labels **"unverified"** |

- All tiers **fail-closed**: no extraction, no install, no launch on mismatch.
- Registry hashes: CI pulls latest official assets, cross-checks against upstream values where published, human-approved PR.

## 6. Process & command line

- Arguments passed as lists (`Process.start`), **never** shell-concatenated strings.
- Game binaries must be `isWithin(versions/)`; no executing arbitrary files outside the data root.
- Termination targets only PIDs the launcher spawned.

## 7. Data & credentials

- GitHub PAT stored in `settings.json` (local plaintext, documented); logs and diagnostic bundles run through a redaction filter (`ghp_`/`github_pat_`, `Bearer`).
- No telemetry, no crash reporting (opt-in reporting re-evaluated at M7).
- The launcher never modifies game file formats it doesn't own (only edits config / registers content) — limiting its own supply-chain blast radius.

## 8. Dependency auditing

- `pubspec.lock` / `docs/package-lock.json` committed; reproducible builds.
- Dependabot: github-actions + npm (pub after M1).
- New dependency admission: justification, maintenance health, AGPL-compatible license, transitive size.
- `osv-scanner` CI job reserved for M7.

## 9. Release security

- Releases ship `sha256sums.txt`; artifacts built by GitHub Actions from tags — maintainers never hand-upload binaries.
- Windows Authenticode / macOS notarization evaluated at M7; until then, user verification steps are documented.
