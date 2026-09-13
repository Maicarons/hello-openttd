// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'hello-openttd';

  @override
  String get navHome => '首页';

  @override
  String get navVersions => '版本管理';

  @override
  String get navLaunch => '启动';

  @override
  String get navConfig => '配置';

  @override
  String get navMods => '模组中心';

  @override
  String get navSaves => '存档管理';

  @override
  String get navSettings => '设置';

  @override
  String get refresh => '刷新';

  @override
  String get cancel => '取消';

  @override
  String get ok => '确定';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get close => '关闭';

  @override
  String get retry => '重试';

  @override
  String get search => '搜索';

  @override
  String get openFolder => '打开目录';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get install => '安装';

  @override
  String get uninstall => '卸载';

  @override
  String get launch => '启动';

  @override
  String get browse => '浏览';

  @override
  String get import => '导入';

  @override
  String get export => '导出';

  @override
  String get backup => '备份';

  @override
  String get restore => '恢复';

  @override
  String get confirm => '确认';

  @override
  String get loading => '加载中…';

  @override
  String get empty => '暂无内容';

  @override
  String get errorTitle => '出错了';

  @override
  String get errorNetwork => '网络错误，请检查网络或更换镜像。';

  @override
  String get errorTimeout => '连接超时。';

  @override
  String get errorChecksum => '文件校验失败，已终止安装。';

  @override
  String get errorPath => '检测到不安全的路径，操作已拒绝。';

  @override
  String get errorDisk => '磁盘读写失败。';

  @override
  String get errorParse => '数据解析失败。';

  @override
  String get errorUrlInvalid => 'URL 不合法或使用了不受支持的协议。';

  @override
  String get errorProcess => '进程启动失败。';

  @override
  String get errorNotFound => '未找到所需内容。';

  @override
  String get errorConflict => '目标已存在。';

  @override
  String get errorCancelled => '操作已取消。';

  @override
  String get errorUnknown => '发生未知错误。';

  @override
  String get errorDiskFull => '磁盘空间不足。';

  @override
  String get homeTitle => '启动台';

  @override
  String get homeSelectVersion => '选择一个已安装的版本';

  @override
  String get homeNoVersions => '还没有安装任何版本。\n去「版本管理」安装一个吧。';

  @override
  String get homeLaunch => '启动游戏';

  @override
  String get homeRecentRuns => '最近运行';

  @override
  String homeLastLaunched(String time) {
    return '上次启动：$time';
  }

  @override
  String get homeStatsVersions => '已装版本';

  @override
  String get homeStatsRuns => '累计启动';

  @override
  String get homeStatsUnverified => '未校验哈希';

  @override
  String get versionsTitle => '版本管理';

  @override
  String get versionsSource => '版本源';

  @override
  String get versionsInstallHint => '选择版本源，然后安装一个发行版。';

  @override
  String get versionsAvailable => '可用版本';

  @override
  String get versionsInstalled => '已安装';

  @override
  String get versionsLatest => '最新';

  @override
  String get versionsUpdateAvailable => '有更新';

  @override
  String get versionsUpToDate => '已是最新';

  @override
  String get versionsLocal => '本地';

  @override
  String versionsInstallConfirmTitle(String version) {
    return '安装 $version？';
  }

  @override
  String get versionsInstallConfirmBody => '将下载并解压到数据目录。带 SHA-256 的资产会强制校验。';

  @override
  String get versionsUnverifiedHash => '该资产未提供校验和，安装后哈希将记录为“未验证”。';

  @override
  String versionsUninstallConfirmTitle(String version) {
    return '卸载 $version？';
  }

  @override
  String get versionsUninstallBody => '版本目录将被删除。';

  @override
  String get versionsUninstallWithData => '同时删除该版本的配置与存档';

  @override
  String get versionsDownloading => '下载中';

  @override
  String get versionsVerifying => '校验中…';

  @override
  String get versionsExtracting => '解压中…';

  @override
  String get versionsFinishing => '完成…';

  @override
  String get versionsInstallDone => '安装完成';

  @override
  String get versionsAdopt => '添加本地版本';

  @override
  String get versionsAdoptHint => '指向一个已存在的 OpenTTD 目录（含 openttd 可执行文件）。';

  @override
  String get versionsConfigIndependent => '独立配置';

  @override
  String get versionsConfigShared => '共享配置';

  @override
  String get versionsPreRelease => '预发布';

  @override
  String get versionsStable => '稳定版';

  @override
  String get launchTitle => '启动';

  @override
  String get launchMode => '启动方式';

  @override
  String get launchModeNewGame => '新游戏';

  @override
  String get launchModeLoadSave => '载入存档';

  @override
  String get launchModeJoinServer => '加入服务器';

  @override
  String get launchModeDedicated => '专用服务器';

  @override
  String get launchServerAddress => '服务器地址 (host[:port])';

  @override
  String get launchServerPassword => '服务器密码（可选）';

  @override
  String get launchResolution => '分辨率 (如 1920x1080)';

  @override
  String get launchExtraArgs => '附加参数（原样附加）';

  @override
  String get launchPreview => '命令行预览';

  @override
  String get launchRun => '▶ 启动';

  @override
  String get launchRunningWarningShared => '共享配置模式下多开可能互相覆盖配置，确认继续？';

  @override
  String get launchRuns => '运行记录';

  @override
  String launchRunExit(int code) {
    return '退出码 $code';
  }

  @override
  String get launchRunRunning => '运行中';

  @override
  String get launchStop => '结束进程';

  @override
  String get launchViewLog => '查看日志';

  @override
  String get launchNoRuns => '还没有启动过游戏。';

  @override
  String get launchSelectSave => '选择存档';

  @override
  String get configTitle => '配置编辑';

  @override
  String get configNoVersion => '请先选择一个版本。';

  @override
  String get configFormView => '表单视图';

  @override
  String get configRawView => '原始视图';

  @override
  String get configSearchHint => '搜索键名或说明…';

  @override
  String get configSaveHint => '保存前会自动生成 .bak 备份。';

  @override
  String configSaved(String backup) {
    return '已保存（备份：$backup）';
  }

  @override
  String get configSavedNoBackup => '已保存';

  @override
  String configInvalidValue(String value) {
    return '取值不合法：$value';
  }

  @override
  String get configOtherKeys => '其他键（原始编辑）';

  @override
  String get configSection => '分区';

  @override
  String get modsTitle => '模组中心';

  @override
  String get modsTypeNewgrf => 'NewGRF';

  @override
  String get modsTypeAi => 'AI';

  @override
  String get modsTypeGameScript => 'GameScript';

  @override
  String get modsTypeMusic => '音轨集';

  @override
  String get modsTabOnline => '在线（BaNaNaS）';

  @override
  String get modsTabInstalled => '已安装';

  @override
  String get modsSearchHint => '搜索名称、作者、描述…';

  @override
  String get modsDownloadInGame =>
      'BaNaNaS 不提供直接下载链接（内容仅能通过游戏内下载）。点击下方按钮在浏览器打开该模组页面，或在游戏内 Content Download 安装。';

  @override
  String get modsOpenWeb => '打开网页';

  @override
  String get modsImportLocal => '导入本地文件';

  @override
  String get modsImportHint =>
      '支持 .tar（BaNaNaS 包）与 .grf，将复制到该版本 content_download 目录。';

  @override
  String modsImported(String path) {
    return '已导入：$path';
  }

  @override
  String modsDeleteConfirm(String name) {
    return '删除 $name？';
  }

  @override
  String get modsInstalledEmpty => '该版本还没有安装任何内容。';

  @override
  String get modsVersions => '版本';

  @override
  String get modsBy => '作者';

  @override
  String get savesTitle => '存档管理';

  @override
  String get savesEmpty => '还没有存档。启动游戏后创建。';

  @override
  String get savesSearchHint => '按名称搜索…';

  @override
  String get savesGroupSaves => '存档';

  @override
  String get savesGroupAutosave => '自动存档';

  @override
  String get savesGroupScenarios => '场景';

  @override
  String get savesGroupHeightmaps => '高度图';

  @override
  String savesDeleteConfirm(String name) {
    return '删除 $name？（移入启动器回收站）';
  }

  @override
  String savesBackupDone(String name) {
    return '备份完成：$name';
  }

  @override
  String get savesBackups => '备份列表';

  @override
  String get savesBackupsEmpty => '还没有备份。';

  @override
  String get savesRestoreDone => '恢复完成';

  @override
  String get savesImportPick => '选择要导入的 .sav / .scn 文件';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsGeneral => '常规';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsDataRoot => '数据目录';

  @override
  String get settingsPortable => '便携模式';

  @override
  String get settingsOpenDataRoot => '打开数据目录';

  @override
  String get settingsDownloads => '下载与镜像';

  @override
  String get settingsMirrorStrategy => '镜像策略';

  @override
  String get settingsMirrorAuto => '自动（测速选优）';

  @override
  String get settingsMirrorFastest => '最快优先';

  @override
  String get settingsMirrorFixed => '固定镜像';

  @override
  String get settingsMirrorOfficial => '仅官方源';

  @override
  String get settingsMirrors => '镜像列表';

  @override
  String get settingsAddMirror => '添加镜像';

  @override
  String get settingsMirrorName => '名称';

  @override
  String settingsMirrorTemplate(String url) {
    return 'URL 模板（$url 占位）';
  }

  @override
  String get settingsGithubToken => 'GitHub 访问令牌（可选）';

  @override
  String get settingsGithubTokenHint => '仅保存在本地，用于提升 API 限额。日志会自动脱敏。';

  @override
  String get settingsAdvanced => '高级';

  @override
  String get settingsOpenLogs => '打开日志目录';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutBody =>
      'hello-openttd — 开源 OpenTTD 启动器（AGPL-3.0）。与 OpenTTD 官方无隶属关系。';

  @override
  String get settingsMirrorAdded => '镜像已添加';

  @override
  String get settingsProbeNow => '立即测速';

  @override
  String settingsProbeResult(String name, int ms) {
    return '$name: $ms ms';
  }

  @override
  String settingsProbeFailed(String name) {
    return '$name: 不可达';
  }

  @override
  String get downloadUnverifiedLabel => '未验证';

  @override
  String get downloadVerifiedLabel => '已校验';

  @override
  String versionLabelFormat(String source, String version) {
    return '$source $version';
  }
}
