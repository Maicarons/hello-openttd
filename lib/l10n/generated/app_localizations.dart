import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'OpenDepot'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get navHome;

  /// No description provided for @navVersions.
  ///
  /// In zh, this message translates to:
  /// **'版本管理'**
  String get navVersions;

  /// No description provided for @navLaunch.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get navLaunch;

  /// No description provided for @navConfig.
  ///
  /// In zh, this message translates to:
  /// **'配置'**
  String get navConfig;

  /// No description provided for @navMods.
  ///
  /// In zh, this message translates to:
  /// **'模组中心'**
  String get navMods;

  /// No description provided for @navSaves.
  ///
  /// In zh, this message translates to:
  /// **'存档管理'**
  String get navSaves;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get navSettings;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @openFolder.
  ///
  /// In zh, this message translates to:
  /// **'打开目录'**
  String get openFolder;

  /// No description provided for @copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In zh, this message translates to:
  /// **'已复制'**
  String get copied;

  /// No description provided for @install.
  ///
  /// In zh, this message translates to:
  /// **'安装'**
  String get install;

  /// No description provided for @uninstall.
  ///
  /// In zh, this message translates to:
  /// **'卸载'**
  String get uninstall;

  /// No description provided for @launch.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get launch;

  /// No description provided for @browse.
  ///
  /// In zh, this message translates to:
  /// **'浏览'**
  String get browse;

  /// No description provided for @import.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get import;

  /// No description provided for @export.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get export;

  /// No description provided for @backup.
  ///
  /// In zh, this message translates to:
  /// **'备份'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get restore;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get loading;

  /// No description provided for @empty.
  ///
  /// In zh, this message translates to:
  /// **'暂无内容'**
  String get empty;

  /// No description provided for @errorTitle.
  ///
  /// In zh, this message translates to:
  /// **'出错了'**
  String get errorTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络错误，请检查网络或更换镜像。'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In zh, this message translates to:
  /// **'连接超时。'**
  String get errorTimeout;

  /// No description provided for @errorChecksum.
  ///
  /// In zh, this message translates to:
  /// **'文件校验失败，已终止安装。'**
  String get errorChecksum;

  /// No description provided for @errorPath.
  ///
  /// In zh, this message translates to:
  /// **'检测到不安全的路径，操作已拒绝。'**
  String get errorPath;

  /// No description provided for @errorDisk.
  ///
  /// In zh, this message translates to:
  /// **'磁盘读写失败。'**
  String get errorDisk;

  /// No description provided for @errorParse.
  ///
  /// In zh, this message translates to:
  /// **'数据解析失败。'**
  String get errorParse;

  /// No description provided for @errorUrlInvalid.
  ///
  /// In zh, this message translates to:
  /// **'URL 不合法或使用了不受支持的协议。'**
  String get errorUrlInvalid;

  /// No description provided for @errorProcess.
  ///
  /// In zh, this message translates to:
  /// **'进程启动失败。'**
  String get errorProcess;

  /// No description provided for @errorNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到所需内容。'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In zh, this message translates to:
  /// **'目标已存在。'**
  String get errorConflict;

  /// No description provided for @errorCancelled.
  ///
  /// In zh, this message translates to:
  /// **'操作已取消。'**
  String get errorCancelled;

  /// No description provided for @errorUnknown.
  ///
  /// In zh, this message translates to:
  /// **'发生未知错误。'**
  String get errorUnknown;

  /// No description provided for @errorDiskFull.
  ///
  /// In zh, this message translates to:
  /// **'磁盘空间不足。'**
  String get errorDiskFull;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'启动台'**
  String get homeTitle;

  /// No description provided for @homeSelectVersion.
  ///
  /// In zh, this message translates to:
  /// **'选择一个已安装的版本'**
  String get homeSelectVersion;

  /// No description provided for @homeNoVersions.
  ///
  /// In zh, this message translates to:
  /// **'还没有安装任何版本。\n去「版本管理」安装一个吧。'**
  String get homeNoVersions;

  /// No description provided for @homeLaunch.
  ///
  /// In zh, this message translates to:
  /// **'启动游戏'**
  String get homeLaunch;

  /// No description provided for @homeRecentRuns.
  ///
  /// In zh, this message translates to:
  /// **'最近运行'**
  String get homeRecentRuns;

  /// No description provided for @homeLastLaunched.
  ///
  /// In zh, this message translates to:
  /// **'上次启动：{time}'**
  String homeLastLaunched(String time);

  /// No description provided for @homeStatsVersions.
  ///
  /// In zh, this message translates to:
  /// **'已装版本'**
  String get homeStatsVersions;

  /// No description provided for @homeStatsRuns.
  ///
  /// In zh, this message translates to:
  /// **'累计启动'**
  String get homeStatsRuns;

  /// No description provided for @homeStatsUnverified.
  ///
  /// In zh, this message translates to:
  /// **'未校验哈希'**
  String get homeStatsUnverified;

  /// No description provided for @versionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'版本管理'**
  String get versionsTitle;

  /// No description provided for @versionsSource.
  ///
  /// In zh, this message translates to:
  /// **'版本源'**
  String get versionsSource;

  /// No description provided for @versionsInstallHint.
  ///
  /// In zh, this message translates to:
  /// **'选择版本源，然后安装一个发行版。'**
  String get versionsInstallHint;

  /// No description provided for @versionsAvailable.
  ///
  /// In zh, this message translates to:
  /// **'可用版本'**
  String get versionsAvailable;

  /// No description provided for @versionsInstalled.
  ///
  /// In zh, this message translates to:
  /// **'已安装'**
  String get versionsInstalled;

  /// No description provided for @versionsLatest.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get versionsLatest;

  /// No description provided for @versionsUpdateAvailable.
  ///
  /// In zh, this message translates to:
  /// **'有更新'**
  String get versionsUpdateAvailable;

  /// No description provided for @versionsUpToDate.
  ///
  /// In zh, this message translates to:
  /// **'已是最新'**
  String get versionsUpToDate;

  /// No description provided for @versionsLocal.
  ///
  /// In zh, this message translates to:
  /// **'本地'**
  String get versionsLocal;

  /// No description provided for @versionsInstallConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'安装 {version}？'**
  String versionsInstallConfirmTitle(String version);

  /// No description provided for @versionsInstallConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'将下载并解压到数据目录。带 SHA-256 的资产会强制校验。'**
  String get versionsInstallConfirmBody;

  /// No description provided for @versionsUnverifiedHash.
  ///
  /// In zh, this message translates to:
  /// **'该资产未提供校验和，安装后哈希将记录为“未验证”。'**
  String get versionsUnverifiedHash;

  /// No description provided for @versionsUninstallConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'卸载 {version}？'**
  String versionsUninstallConfirmTitle(String version);

  /// No description provided for @versionsUninstallBody.
  ///
  /// In zh, this message translates to:
  /// **'版本目录将被删除。'**
  String get versionsUninstallBody;

  /// No description provided for @versionsUninstallWithData.
  ///
  /// In zh, this message translates to:
  /// **'同时删除该版本的配置与存档'**
  String get versionsUninstallWithData;

  /// No description provided for @versionsDownloading.
  ///
  /// In zh, this message translates to:
  /// **'下载中'**
  String get versionsDownloading;

  /// No description provided for @versionsVerifying.
  ///
  /// In zh, this message translates to:
  /// **'校验中…'**
  String get versionsVerifying;

  /// No description provided for @versionsExtracting.
  ///
  /// In zh, this message translates to:
  /// **'解压中…'**
  String get versionsExtracting;

  /// No description provided for @versionsFinishing.
  ///
  /// In zh, this message translates to:
  /// **'完成…'**
  String get versionsFinishing;

  /// No description provided for @versionsInstallDone.
  ///
  /// In zh, this message translates to:
  /// **'安装完成'**
  String get versionsInstallDone;

  /// No description provided for @versionsAdopt.
  ///
  /// In zh, this message translates to:
  /// **'添加本地版本'**
  String get versionsAdopt;

  /// No description provided for @versionsAdoptHint.
  ///
  /// In zh, this message translates to:
  /// **'指向一个已存在的 OpenTTD 目录（含 openttd 可执行文件）。'**
  String get versionsAdoptHint;

  /// No description provided for @versionsConfigIndependent.
  ///
  /// In zh, this message translates to:
  /// **'独立配置'**
  String get versionsConfigIndependent;

  /// No description provided for @versionsConfigShared.
  ///
  /// In zh, this message translates to:
  /// **'共享配置'**
  String get versionsConfigShared;

  /// No description provided for @versionsPreRelease.
  ///
  /// In zh, this message translates to:
  /// **'预发布'**
  String get versionsPreRelease;

  /// No description provided for @versionsStable.
  ///
  /// In zh, this message translates to:
  /// **'稳定版'**
  String get versionsStable;

  /// No description provided for @launchTitle.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get launchTitle;

  /// No description provided for @launchMode.
  ///
  /// In zh, this message translates to:
  /// **'启动方式'**
  String get launchMode;

  /// No description provided for @launchModeNewGame.
  ///
  /// In zh, this message translates to:
  /// **'新游戏'**
  String get launchModeNewGame;

  /// No description provided for @launchModeLoadSave.
  ///
  /// In zh, this message translates to:
  /// **'载入存档'**
  String get launchModeLoadSave;

  /// No description provided for @launchModeJoinServer.
  ///
  /// In zh, this message translates to:
  /// **'加入服务器'**
  String get launchModeJoinServer;

  /// No description provided for @launchModeDedicated.
  ///
  /// In zh, this message translates to:
  /// **'专用服务器'**
  String get launchModeDedicated;

  /// No description provided for @launchServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'服务器地址 (host[:port])'**
  String get launchServerAddress;

  /// No description provided for @launchServerPassword.
  ///
  /// In zh, this message translates to:
  /// **'服务器密码（可选）'**
  String get launchServerPassword;

  /// No description provided for @launchResolution.
  ///
  /// In zh, this message translates to:
  /// **'分辨率 (如 1920x1080)'**
  String get launchResolution;

  /// No description provided for @launchExtraArgs.
  ///
  /// In zh, this message translates to:
  /// **'附加参数（原样附加）'**
  String get launchExtraArgs;

  /// No description provided for @launchPreview.
  ///
  /// In zh, this message translates to:
  /// **'命令行预览'**
  String get launchPreview;

  /// No description provided for @launchRun.
  ///
  /// In zh, this message translates to:
  /// **'▶ 启动'**
  String get launchRun;

  /// No description provided for @launchRunningWarningShared.
  ///
  /// In zh, this message translates to:
  /// **'共享配置模式下多开可能互相覆盖配置，确认继续？'**
  String get launchRunningWarningShared;

  /// No description provided for @launchRuns.
  ///
  /// In zh, this message translates to:
  /// **'运行记录'**
  String get launchRuns;

  /// No description provided for @launchRunExit.
  ///
  /// In zh, this message translates to:
  /// **'退出码 {code}'**
  String launchRunExit(int code);

  /// No description provided for @launchRunRunning.
  ///
  /// In zh, this message translates to:
  /// **'运行中'**
  String get launchRunRunning;

  /// No description provided for @launchStop.
  ///
  /// In zh, this message translates to:
  /// **'结束进程'**
  String get launchStop;

  /// No description provided for @launchViewLog.
  ///
  /// In zh, this message translates to:
  /// **'查看日志'**
  String get launchViewLog;

  /// No description provided for @launchNoRuns.
  ///
  /// In zh, this message translates to:
  /// **'还没有启动过游戏。'**
  String get launchNoRuns;

  /// No description provided for @launchSelectSave.
  ///
  /// In zh, this message translates to:
  /// **'选择存档'**
  String get launchSelectSave;

  /// No description provided for @configTitle.
  ///
  /// In zh, this message translates to:
  /// **'配置编辑'**
  String get configTitle;

  /// No description provided for @configNoVersion.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个版本。'**
  String get configNoVersion;

  /// No description provided for @configFormView.
  ///
  /// In zh, this message translates to:
  /// **'表单视图'**
  String get configFormView;

  /// No description provided for @configRawView.
  ///
  /// In zh, this message translates to:
  /// **'原始视图'**
  String get configRawView;

  /// No description provided for @configSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索键名或说明…'**
  String get configSearchHint;

  /// No description provided for @configSaveHint.
  ///
  /// In zh, this message translates to:
  /// **'保存前会自动生成 .bak 备份。'**
  String get configSaveHint;

  /// No description provided for @configSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存（备份：{backup}）'**
  String configSaved(String backup);

  /// No description provided for @configSavedNoBackup.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get configSavedNoBackup;

  /// No description provided for @configInvalidValue.
  ///
  /// In zh, this message translates to:
  /// **'取值不合法：{value}'**
  String configInvalidValue(String value);

  /// No description provided for @configOtherKeys.
  ///
  /// In zh, this message translates to:
  /// **'其他键（原始编辑）'**
  String get configOtherKeys;

  /// No description provided for @configSection.
  ///
  /// In zh, this message translates to:
  /// **'分区'**
  String get configSection;

  /// No description provided for @modsTitle.
  ///
  /// In zh, this message translates to:
  /// **'模组中心'**
  String get modsTitle;

  /// No description provided for @modsTypeNewgrf.
  ///
  /// In zh, this message translates to:
  /// **'NewGRF'**
  String get modsTypeNewgrf;

  /// No description provided for @modsTypeAi.
  ///
  /// In zh, this message translates to:
  /// **'AI'**
  String get modsTypeAi;

  /// No description provided for @modsTypeGameScript.
  ///
  /// In zh, this message translates to:
  /// **'GameScript'**
  String get modsTypeGameScript;

  /// No description provided for @modsTypeMusic.
  ///
  /// In zh, this message translates to:
  /// **'音轨集'**
  String get modsTypeMusic;

  /// No description provided for @modsTabOnline.
  ///
  /// In zh, this message translates to:
  /// **'在线（BaNaNaS）'**
  String get modsTabOnline;

  /// No description provided for @modsTabInstalled.
  ///
  /// In zh, this message translates to:
  /// **'已安装'**
  String get modsTabInstalled;

  /// No description provided for @modsSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索名称、作者、描述…'**
  String get modsSearchHint;

  /// No description provided for @modsDownloadInGame.
  ///
  /// In zh, this message translates to:
  /// **'BaNaNaS 不提供直接下载链接（内容仅能通过游戏内下载）。点击下方按钮在浏览器打开该模组页面，或在游戏内 Content Download 安装。'**
  String get modsDownloadInGame;

  /// No description provided for @modsOpenWeb.
  ///
  /// In zh, this message translates to:
  /// **'打开网页'**
  String get modsOpenWeb;

  /// No description provided for @modsImportLocal.
  ///
  /// In zh, this message translates to:
  /// **'导入本地文件'**
  String get modsImportLocal;

  /// No description provided for @modsImportHint.
  ///
  /// In zh, this message translates to:
  /// **'支持 .tar（BaNaNaS 包）与 .grf，将复制到该版本 content_download 目录。'**
  String get modsImportHint;

  /// No description provided for @modsImported.
  ///
  /// In zh, this message translates to:
  /// **'已导入：{path}'**
  String modsImported(String path);

  /// No description provided for @modsDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除 {name}？'**
  String modsDeleteConfirm(String name);

  /// No description provided for @modsInstalledEmpty.
  ///
  /// In zh, this message translates to:
  /// **'该版本还没有安装任何内容。'**
  String get modsInstalledEmpty;

  /// No description provided for @modsVersions.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get modsVersions;

  /// No description provided for @modsBy.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get modsBy;

  /// No description provided for @savesTitle.
  ///
  /// In zh, this message translates to:
  /// **'存档管理'**
  String get savesTitle;

  /// No description provided for @savesEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有存档。启动游戏后创建。'**
  String get savesEmpty;

  /// No description provided for @savesSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'按名称搜索…'**
  String get savesSearchHint;

  /// No description provided for @savesGroupSaves.
  ///
  /// In zh, this message translates to:
  /// **'存档'**
  String get savesGroupSaves;

  /// No description provided for @savesGroupAutosave.
  ///
  /// In zh, this message translates to:
  /// **'自动存档'**
  String get savesGroupAutosave;

  /// No description provided for @savesGroupScenarios.
  ///
  /// In zh, this message translates to:
  /// **'场景'**
  String get savesGroupScenarios;

  /// No description provided for @savesGroupHeightmaps.
  ///
  /// In zh, this message translates to:
  /// **'高度图'**
  String get savesGroupHeightmaps;

  /// No description provided for @savesDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除 {name}？（移入启动器回收站）'**
  String savesDeleteConfirm(String name);

  /// No description provided for @savesBackupDone.
  ///
  /// In zh, this message translates to:
  /// **'备份完成：{name}'**
  String savesBackupDone(String name);

  /// No description provided for @savesBackups.
  ///
  /// In zh, this message translates to:
  /// **'备份列表'**
  String get savesBackups;

  /// No description provided for @savesBackupsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有备份。'**
  String get savesBackupsEmpty;

  /// No description provided for @savesRestoreDone.
  ///
  /// In zh, this message translates to:
  /// **'恢复完成'**
  String get savesRestoreDone;

  /// No description provided for @savesImportPick.
  ///
  /// In zh, this message translates to:
  /// **'选择要导入的 .sav / .scn 文件'**
  String get savesImportPick;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In zh, this message translates to:
  /// **'常规'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsTheme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get settingsThemeDark;

  /// No description provided for @settingsDataRoot.
  ///
  /// In zh, this message translates to:
  /// **'数据目录'**
  String get settingsDataRoot;

  /// No description provided for @settingsPortable.
  ///
  /// In zh, this message translates to:
  /// **'便携模式'**
  String get settingsPortable;

  /// No description provided for @settingsOpenDataRoot.
  ///
  /// In zh, this message translates to:
  /// **'打开数据目录'**
  String get settingsOpenDataRoot;

  /// No description provided for @settingsDownloads.
  ///
  /// In zh, this message translates to:
  /// **'下载与镜像'**
  String get settingsDownloads;

  /// No description provided for @settingsMirrorStrategy.
  ///
  /// In zh, this message translates to:
  /// **'镜像策略'**
  String get settingsMirrorStrategy;

  /// No description provided for @settingsMirrorAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动（测速选优）'**
  String get settingsMirrorAuto;

  /// No description provided for @settingsMirrorFastest.
  ///
  /// In zh, this message translates to:
  /// **'最快优先'**
  String get settingsMirrorFastest;

  /// No description provided for @settingsMirrorFixed.
  ///
  /// In zh, this message translates to:
  /// **'固定镜像'**
  String get settingsMirrorFixed;

  /// No description provided for @settingsMirrorOfficial.
  ///
  /// In zh, this message translates to:
  /// **'仅官方源'**
  String get settingsMirrorOfficial;

  /// No description provided for @settingsMirrors.
  ///
  /// In zh, this message translates to:
  /// **'镜像列表'**
  String get settingsMirrors;

  /// No description provided for @settingsAddMirror.
  ///
  /// In zh, this message translates to:
  /// **'添加镜像'**
  String get settingsAddMirror;

  /// No description provided for @settingsMirrorName.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get settingsMirrorName;

  /// No description provided for @settingsMirrorTemplate.
  ///
  /// In zh, this message translates to:
  /// **'URL 模板（{url} 占位）'**
  String settingsMirrorTemplate(String url);

  /// No description provided for @settingsGithubToken.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 访问令牌（可选）'**
  String get settingsGithubToken;

  /// No description provided for @settingsGithubTokenHint.
  ///
  /// In zh, this message translates to:
  /// **'仅保存在本地，用于提升 API 限额。日志会自动脱敏。'**
  String get settingsGithubTokenHint;

  /// No description provided for @settingsAdvanced.
  ///
  /// In zh, this message translates to:
  /// **'高级'**
  String get settingsAdvanced;

  /// No description provided for @settingsOpenLogs.
  ///
  /// In zh, this message translates to:
  /// **'打开日志目录'**
  String get settingsOpenLogs;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In zh, this message translates to:
  /// **'OpenDepot — 开源 OpenTTD 启动器（AGPL-3.0）。与 OpenTTD 官方无隶属关系。'**
  String get settingsAboutBody;

  /// No description provided for @settingsMirrorAdded.
  ///
  /// In zh, this message translates to:
  /// **'镜像已添加'**
  String get settingsMirrorAdded;

  /// No description provided for @settingsProbeNow.
  ///
  /// In zh, this message translates to:
  /// **'立即测速'**
  String get settingsProbeNow;

  /// No description provided for @settingsProbeResult.
  ///
  /// In zh, this message translates to:
  /// **'{name}: {ms} ms'**
  String settingsProbeResult(String name, int ms);

  /// No description provided for @settingsProbeFailed.
  ///
  /// In zh, this message translates to:
  /// **'{name}: 不可达'**
  String settingsProbeFailed(String name);

  /// No description provided for @downloadUnverifiedLabel.
  ///
  /// In zh, this message translates to:
  /// **'未验证'**
  String get downloadUnverifiedLabel;

  /// No description provided for @downloadVerifiedLabel.
  ///
  /// In zh, this message translates to:
  /// **'已校验'**
  String get downloadVerifiedLabel;

  /// No description provided for @versionLabelFormat.
  ///
  /// In zh, this message translates to:
  /// **'{source} {version}'**
  String versionLabelFormat(String source, String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
