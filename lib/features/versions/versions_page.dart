import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging.dart';
import '../../core/utils/format.dart';
import '../../data/models/version_models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/service_providers.dart';
import '../../services/version_source/version_installer.dart';
import '../../services/version_source/version_source.dart';
import '../../ui/widgets/common.dart';

/// Version management: sources, install wizard, installed list.
class VersionsPage extends ConsumerStatefulWidget {
  const VersionsPage({super.key});

  @override
  ConsumerState<VersionsPage> createState() => _VersionsPageState();
}

class _VersionsPageState extends ConsumerState<VersionsPage> {
  List<VersionSource> _sources = [];
  VersionSource? _selected;
  AsyncValue<List<SourceRelease>>? _releases;
  StreamSubscription<RunExit>? _exitSub;

  @override
  void initState() {
    super.initState();
    _sources = ref.read(sourceRegistryProvider).all();
    _selected = _sources.firstOrNull;
    if (_selected != null) _loadReleases();
    _exitSub ??= ref.read(processServiceProvider).exits.listen((_) {
      ref.read(installedVersionsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _exitSub?.cancel();
    super.dispose();
  }

  Future<void> _loadReleases({bool refresh = false}) async {
    final source = _selected;
    if (source == null) return;
    setState(() => _releases = const AsyncValue.loading());
    try {
      final list = await source.listReleases();
      list.sort((a, b) => compareVersions(b.version, a.version));
      if (mounted) setState(() => _releases = AsyncValue.data(list));
    } catch (e, st) {
      Log.error('load releases (${source.id}) failed', e, st);
      if (mounted) setState(() => _releases = AsyncValue.error(e, st));
    }
  }

  Future<void> _install(SourceRelease release) async {
    final l = AppLocalizations.of(context)!;
    var configMode = 'independent';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.versionsInstallConfirmTitle(release.version)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.versionsInstallConfirmBody),
              const SizedBox(height: 12),
              RadioGroup<String>(
                groupValue: configMode,
                onChanged: (v) => setState(() => configMode = v!),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'independent',
                      title: Text(l.versionsConfigIndependent),
                    ),
                    RadioListTile<String>(
                      value: 'shared',
                      title: Text(l.versionsConfigShared),
                    ),
                  ],
                ),
              ),
              if (release.assets.values.every((a) => a.sha256 == null))
                Text(l.versionsUnverifiedHash,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
            FilledButton(
                onPressed: () => Navigator.pop(context, true), child: Text(l.install)),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final versionId = _selected!.id;
    final platform = PlatformTarget.detect();
    final progressText = ValueNotifier<String>(l.versionsDownloading);
    final progressValue = ValueNotifier<double?>(null);

    final installFuture = () async {
      try {
        await for (final progress
            in ref.read(versionInstallerProvider).install(
                  release: release,
                  platform: platform,
                  configMode: configMode,
                  versionId: versionId,
                )) {
          switch (progress.phase) {
            case InstallPhase.downloading:
              progressText.value = '${l.versionsDownloading} '
                  '${formatBytes(progress.received)}'
                  '${progress.total != null ? ' / ${formatBytes(progress.total)}' : ''}';
              if (progress.total != null && progress.total! > 0) {
                progressValue.value = (progress.received ?? 0) / progress.total!;
              }
            case InstallPhase.verifying:
              progressValue.value = null;
              progressText.value = l.versionsVerifying;
            case InstallPhase.extracting:
              progressValue.value = null;
              progressText.value = l.versionsExtracting;
            case InstallPhase.finishing:
              progressValue.value = null;
              progressText.value = l.versionsFinishing;
          }
        }
        ref.read(installedVersionsProvider.notifier).refresh();
        if (mounted) showInfo(context, l.versionsInstallDone);
      } catch (e, st) {
        if (mounted) showError(context, e, st);
      } finally {
        if (mounted) {
          final navigator = Navigator.of(context, rootNavigator: true);
          if (navigator.canPop()) navigator.pop();
        }
      }
    }();

    unawaited(installFuture);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 72,
          child: ValueListenableBuilder<String>(
            valueListenable: progressText,
            builder: (context, text, _) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<double?>(
                  valueListenable: progressValue,
                  builder: (context, value, _) => value == null
                      ? const LinearProgressIndicator()
                      : LinearProgressIndicator(value: value.clamp(0.0, 1.0)),
                ),
                const SizedBox(height: 12),
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uninstall(String id, String version) async {
    final l = AppLocalizations.of(context)!;
    var deleteData = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.versionsUninstallConfirmTitle(version)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.versionsUninstallBody),
              CheckboxListTile(
                value: deleteData,
                onChanged: (v) => setState(() => deleteData = v ?? false),
                title: Text(l.versionsUninstallWithData),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
            FilledButton(
                onPressed: () => Navigator.pop(context, true), child: Text(l.uninstall)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      ref.read(versionsServiceProvider).uninstall(id, deleteData: deleteData);
      ref.read(installedVersionsProvider.notifier).refresh();
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  Future<void> _adoptLocal() async {
    final l = AppLocalizations.of(context)!;
    final dirController = TextEditingController();
    final labelController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.versionsAdopt),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.versionsAdoptHint),
            const SizedBox(height: 12),
            TextField(
              controller: dirController,
              decoration: const InputDecoration(hintText: 'C:\\Games\\OpenTTD'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: labelController,
              decoration: InputDecoration(hintText: l.versionsLocal),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.ok)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      ref.read(versionsServiceProvider).adoptLocal(
            directory: dirController.text.trim(),
            versionLabel: labelController.text.trim().isEmpty
                ? l.versionsLocal
                : labelController.text.trim(),
          );
      ref.read(installedVersionsProvider.notifier).refresh();
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final installedAsync = ref.watch(installedVersionsProvider);
    final selectedVersionId = ref.watch(selectedVersionIdProvider);

    return Scaffold(
      body: ListView(
        children: [
          PageHeader(
            title: l.versionsTitle,
            actions: [
              TextButton.icon(
                onPressed: _adoptLocal,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(l.versionsAdopt),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selected?.id,
                    decoration: InputDecoration(labelText: l.versionsSource),
                    items: [
                      for (final s in _sources)
                        DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ],
                    onChanged: (id) {
                      setState(() {
                        _selected = _sources.where((s) => s.id == id).firstOrNull;
                      });
                      _loadReleases();
                    },
                  ),
                ),
                IconButton(
                  tooltip: l.refresh,
                  onPressed: _loadReleases,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          PageHeader(title: l.versionsInstalled),
          installedAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => EmptyState(icon: Icons.error_outline, message: '$e'),
            data: (installed) => Column(
              children: [
                if (installed.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: EmptyState(icon: Icons.inventory_2_outlined, message: l.empty),
                  ),
                for (final v in installed)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: Text(v.label),
                      subtitle: Text(
                          '${formatDateTime(v.installedAt)} · ${v.configMode}'),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          if (v.id == selectedVersionId)
                            const Icon(Icons.check, size: 18),
                          IconButton(
                            tooltip: l.uninstall,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _uninstall(v.id, v.version),
                          ),
                        ],
                      ),
                      onTap: () =>
                          ref.read(selectedVersionIdProvider.notifier).select(v.id),
                    ),
                  ),
              ],
            ),
          ),
          PageHeader(
            title: l.versionsAvailable,
            actions: [
              if (_releases is AsyncData)
                TextButton.icon(
                  onPressed: _loadReleases,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l.refresh),
                ),
            ],
          ),
          _buildReleasesList(l),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReleasesList(AppLocalizations l) {
    final releases = _releases;
    if (releases == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: EmptyState(icon: Icons.download_outlined, message: l.versionsInstallHint),
      );
    }
    return releases.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.all(16),
        child: EmptyState(icon: Icons.error_outline, message: failureMessage(context, e)),
      ),
      data: (list) {
        final platform = PlatformTarget.detect();
        final installable = list.where((r) => r.assets[platform] != null).toList();
        if (installable.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: EmptyState(icon: Icons.download_outlined, message: l.empty),
          );
        }
        return Column(
          children: [
            for (final release in installable)
              ListTile(
                leading: Icon(
                  release.prerelease ? Icons.science_outlined : Icons.verified_outlined,
                  color: release.prerelease ? Colors.orange : null,
                ),
                title: Text(release.version),
                subtitle: Text(
                  '${formatDateTime(release.releasedAt)} · '
                  '${formatBytes(release.assets[platform]?.size)} · '
                  '${release.assets[platform]?.sha256 != null ? l.downloadVerifiedLabel : l.downloadUnverifiedLabel}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () => _install(release),
                  child: Text(l.install),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Rebuild placeholder removed — progress dialog uses ValueNotifier directly.
