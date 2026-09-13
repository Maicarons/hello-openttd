# 安全设计

启动器的基本盘：**它有写磁盘、执行网络请求、启动进程三类高权限行为**，安全设计围绕这三类展开。以下约束为**合并门槛**，PR 模板要求自查。

## 1. 威胁模型（简版 STRIDE）

| 威胁 | 场景 | 缓解 |
|------|------|------|
| 路径遍历 | 恶意文件名/存档名/模组条目逃出预期目录 | `fs_guard` 统一校验（见下） |
| 下载劫持 | 镜像返回恶意内容 | HTTPS-only + SHA-256 fail-closed + 官方源回退 |
| Zip Slip / 链接逃逸 | 归档内 `../`、绝对路径、symlink | 解压逐条目校验 |
| 参数注入 | 文件名/参数含特殊字符 | 无 shell 拼接，列表式传参 |
| SSRF | 自定义镜像/源指向内网 | URL 校验策略 |
| 供应链 | 依赖被投毒 | 锁文件 + Dependabot + 最小依赖面 |
| 凭证泄露 | PAT/密码进日志 | 日志脱敏过滤器 |

## 2. 路径安全（`core/paths/fs_guard.dart`）

**唯一入口**：所有"用户可控字符串 → 文件系统路径"的构造必须经：

```dart
/// 校验 name 可作为单个路径组件，并返回 root 下规范化的目标路径。
/// 失败抛 PathGuardFailure。
Path safeJoin(Path root, String name);
```

规则：

1. 文件名白名单字符集：`A-Za-z0-9._ -` 与 Unicode 字母（`Intl` 判定），长度 1–128；拒绝一切路径分隔符（`/`、`\`、`:`）、空字节与 Windows 保留名（`CON`、`PRN`、`AUX`、`NUL`、`COM1-9`、`LPT1-9`）。
2. `normalize()` 后必须 `isWithin(root)`（处理 `..`、符号链接解析后的真实路径 `resolveSymbolicLinksSync()` 在写入前二次确认）。
3. 内部 id（版本 id、镜像 id、任务 id）更严：`^[a-z0-9][a-z0-9._-]{0,63}$`。

## 3. 归档解压

- **zip**：逐条目校验——拒绝绝对路径、含 `..` 组件；解压总大小上限（默认 4×压缩包大小且 ≤ 2GB，防 zip 炸弹）；条目数上限 50000；symlink 条目一律丢弃并记录。
- **tar**（系统 tar 代理）：`--no-same-owner`（Unix）；解压目标为专用空目录，完成后遍历检查是否存在逃逸（所有文件 `isWithin(target)`），发现即删除整个目录并失败。
- 解压前检查目标卷剩余空间。

## 4. URL 验证（`services/security`）

对**一切**出站 URL（版本源、镜像改写后、BaNaNaS、启动器更新检查）：

1. scheme 仅 `https`（开发构建允许 `http://127.0.0.1`）。
2. 禁 userinfo（`user:pass@host`）、禁 IPv4/IPv6 字面量主机（内网 SSRF 面），域名须含 `.`（不含 localhost，除上述例外）。
3. 重定向：`maxRedirects ≤ 5`，**逐跳重新校验**；`https → http` 降级一律拒绝。
4. 改写型镜像模板：替换后 URL 同样全量校验；模板本身不得包含 scheme 以外协议片段。
5. 下载内容长度上限 2GB；`Content-Type` 不做信任源（镜像站常错，仅记录）。

## 5. 信任模型与校验和

| 层级 | 说明 |
|------|------|
| Tier 1 固定哈希 | 内置版本源注册表为已知发布固定 SHA-256（随启动器更新维护） |
| Tier 2 声明哈希 | 自定义源 JSON 中携带 `sha256` → 强制校验 |
| Tier 3 记录哈希 | 无哈希资产：下载后计算、写入 manifest，UI 标注**"未验证"** |

- 所有层级统一 **fail-closed**：校验不过 → 不解压、不安装、不运行。
- 内置注册表的哈希由 CI 从官方 Releases 拉取后人工核对入库（流程见[发布流程](./release)）。

## 6. 进程与命令行

- 参数列表传递（`Process.start` 的 `arguments`），**永不**经 shell 字符串拼接。
- 游戏二进制路径必须 `isWithin(versions/)`；禁止启动数据根目录之外的任意可执行文件。
- 结束进程仅针对启动器自己拉起的 PID。

## 7. 数据与凭证

- GitHub PAT 仅存 `settings.json`（本地明文，文档明示）；日志、诊断包、错误上报路径统一经过脱敏过滤器（正则匹配 `ghp_`/`github_pat_` 前缀、`Bearer` 头）。
- 无遥测、无崩溃上报（M7 评估 opt-in 上报，另行评审）。
- 不修改游戏文件内容（只登记/编辑配置），降低"启动器成为游戏供应链一环"的风险。

## 8. 依赖审计

- `pubspec.lock` / `docs/package-lock.json` 提交，构建可复现。
- Dependabot：github-actions + npm（pub 待工程落地启用）。
- 新依赖准入：PR 说明用途、维护活跃度、许可证兼容（AGPL 允许的许可证矩阵）与传递依赖规模；优先 Dart/Flutter 官方与广泛使用包。
- CI 预留 `osv-scanner` 扫描 job（M7 启用）。

## 9. 发布安全

- Releases 附 `sha256sums.txt`；产物由 GitHub Actions 从 tag 构建（见[发布流程](./release)），维护者不手工上传二进制。
- Windows Authenticode / macOS 签名公证在 M7 评估（需要证书预算），未签名前在文档中明示用户校验步骤。
