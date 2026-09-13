import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/service_providers.dart';
import '../../services/bananas/bananas_service.dart';
import '../../ui/widgets/common.dart';

/// Mod center: BaNaNaS online browse/search + local content management.
class ModsPage extends ConsumerStatefulWidget {
  const ModsPage({super.key});

  @override
  ConsumerState<ModsPage> createState() => _ModsPageState();
}

class _ModsPageState extends ConsumerState<ModsPage> {
  String _type = 'newgrf';
  bool _online = true;
  List<BananasPackage>? _packages;
  bool _loading = false;
  Object? _error;
  final _searchCtrl = TextEditingController();
  final _importCtrl = TextEditingController();
  List<InstalledContentFile>? _installed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final packages = await ref.read(bananasServiceProvider).browse(_type, forceRefresh: force);
      if (mounted) setState(() => _packages = packages);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _reloadInstalled() {
    final gameDir = ref.read(selectedGameDirProvider);
    if (gameDir == null) {
      setState(() => _installed = null);
      return;
    }
    setState(() {
      try {
        _installed = ref.read(bananasServiceProvider).scanInstalled(gameDir);
      } catch (e, st) {
        showError(context, e, st);
        _installed = null;
      }
    });
  }

  Future<void> _importLocal() async {
    final l = AppLocalizations.of(context)!;
    final gameDir = ref.read(selectedGameDirProvider);
    if (gameDir == null) return;
    try {
      final dest = ref
          .read(bananasServiceProvider)
          .importLocal(gameDir, _importCtrl.text.trim());
      _reloadInstalled();
      if (mounted) showInfo(context, l.modsImported(dest));
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  Future<void> _deleteFile(InstalledContentFile file) async {
    final l = AppLocalizations.of(context)!;
    final gameDir = ref.read(selectedGameDirProvider)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l.modsDeleteConfirm(file.relativePath)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      ref.read(bananasServiceProvider).deleteInstalled(gameDir, file.relativePath);
      _reloadInstalled();
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  void _showDetail(BananasPackage pkg) {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pkg.name),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l.modsBy}: ${pkg.authors.join(', ')}'),
              const SizedBox(height: 4),
              Text('${l.modsVersions}: ${pkg.latestVersion ?? '—'}'),
              const SizedBox(height: 4),
              Text(formatBytes(pkg.latestFilesize)),
              const SizedBox(height: 8),
              Flexible(child: SingleChildScrollView(child: Text(pkg.description))),
              const SizedBox(height: 12),
              Text(l.modsDownloadInGame,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final url = ref.read(bananasServiceProvider).webPageUrl(_type, pkg.id);
              _openExternal(url);
            },
            child: Text(l.modsOpenWeb),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.close)),
        ],
      ),
    );
  }

  Future<void> _openExternal(String url) async {
    try {
      final ok = await _launchUrl(url);
      if (!ok && mounted) showInfo(context, url);
    } catch (e, st) {
      if (mounted) showError(context, e, st);
    }
  }

  Future<bool> _launchUrl(String url) async {
    // Desktop URL opening without extra plugins:
    // windows `start`, macOS `open`, linux `xdg-open`.
    if (Platform.isWindows) {
      final r = await Process.run('cmd', ['/c', 'start', '', url], runInShell: false);
      return r.exitCode == 0;
    }
    if (Platform.isMacOS) {
      final r = await Process.run('open', [url]);
      return r.exitCode == 0;
    }
    final r = await Process.run('xdg-open', [url]);
    return r.exitCode == 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final version = ref.watch(selectedVersionProvider);
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = (_packages ?? const <BananasPackage>[])
        .where((p) =>
            query.isEmpty ||
            p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.authors.any((a) => a.toLowerCase().contains(query)))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: l.modsTitle,
            actions: [
              Text(version?.label ?? l.configNoVersion),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l.modsTabOnline)),
                ButtonSegment(value: false, label: Text(l.modsTabInstalled)),
              ],
              selected: {_online},
              onSelectionChanged: (s) => setState(() {
                _online = s.first;
                if (!_online) _reloadInstalled();
              }),
            ),
          ),
          if (_online) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'newgrf', label: Text(l.modsTypeNewgrf)),
                      ButtonSegment(value: 'ai', label: Text(l.modsTypeAi)),
                      ButtonSegment(
                          value: 'game-script', label: Text(l.modsTypeGameScript)),
                      ButtonSegment(value: 'base-music', label: Text(l.modsTypeMusic)),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) {
                      _type = s.first;
                      _load();
                    },
                  ),
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: l.modsSearchHint,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    tooltip: l.refresh,
                    onPressed: () => _load(force: true),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildOnlineList(l, filtered),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.modsImportHint, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _importCtrl,
                        decoration: InputDecoration(hintText: 'D:\\mods\\ukrs.tar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: version == null ? null : _importLocal,
                      icon: const Icon(Icons.file_open),
                      label: Text(l.import),
                    ),
                  ]),
                ],
              ),
            ),
            Expanded(child: _buildInstalledList(l)),
          ],
        ],
      ),
    );
  }

  Widget _buildOnlineList(AppLocalizations l, List<BananasPackage> filtered) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(icon: Icons.cloud_off, message: failureMessage(context, _error!)),
            TextButton(
              onPressed: () => _load(force: true),
              child: Text(l.retry),
            ),
          ],
        ),
      );
    }
    if (filtered.isEmpty) {
      return EmptyState(icon: Icons.extension_outlined, message: l.empty);
    }
    return ListView(
      children: [
        for (final pkg in filtered)
          ListTile(
            leading: const Icon(Icons.extension_outlined),
            title: Text(pkg.name),
            subtitle: Text(
              '${pkg.authors.join(', ')}'
              ' · ${l.modsVersions} ${pkg.latestVersion ?? '—'}'
              ' · ${formatBytes(pkg.latestFilesize)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _showDetail(pkg),
          ),
      ],
    );
  }

  Widget _buildInstalledList(AppLocalizations l) {
    final installed = _installed;
    if (installed == null || installed.isEmpty) {
      return EmptyState(icon: Icons.extension_off, message: l.modsInstalledEmpty);
    }
    return ListView(
      children: [
        for (final file in installed)
          ListTile(
            dense: true,
            leading: const Icon(Icons.description_outlined),
            title: Text(file.relativePath),
            trailing: Wrap(children: [
              Text(formatBytes(file.size)),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteFile(file),
              ),
            ]),
          ),
      ],
    );
  }
}
