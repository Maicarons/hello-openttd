import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/service_providers.dart';
import '../../services/saves/save_service.dart';
import '../../ui/widgets/common.dart';

/// Save management: scan, search, import/export, backup/restore.
class SavesPage extends ConsumerStatefulWidget {
  const SavesPage({super.key});

  @override
  ConsumerState<SavesPage> createState() => _SavesPageState();
}

class _SavesPageState extends ConsumerState<SavesPage> {
  List<SaveEntry>? _entries;
  List<File>? _backups;
  final _searchCtrl = TextEditingController();
  final _exportCtrl = TextEditingController();
  final _importCtrl = TextEditingController();
  String? _watchedVersionId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final version = ref.read(selectedVersionProvider);
    if (version == null) {
      setState(() {
        _entries = null;
        _backups = null;
      });
      return;
    }
    _watchedVersionId = version.id;
    setState(() {
      try {
        _entries = ref.read(saveServiceProvider).scan(version);
        _backups = ref.read(saveServiceProvider).backups();
      } catch (e, st) {
        showError(context, e, st);
        _entries = null;
      }
    });
  }

  String _groupLabel(AppLocalizations l, String group) => switch (group) {
        'saves' => l.savesGroupSaves,
        'autosave' => l.savesGroupAutosave,
        'scenarios' => l.savesGroupScenarios,
        _ => l.savesGroupHeightmaps,
      };

  Future<void> _import() async {
    final l = AppLocalizations.of(context)!;
    final version = ref.read(selectedVersionProvider);
    if (version == null) return;
    try {
      ref.read(saveServiceProvider).import(version, _importCtrl.text.trim());
      _reload();
      if (mounted) showInfo(context, l.ok);
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  Future<void> _backup() async {
    final l = AppLocalizations.of(context)!;
    final version = ref.read(selectedVersionProvider);
    if (version == null) return;
    try {
      final file = ref.read(saveServiceProvider).backup(version);
      _reload();
      if (mounted) showInfo(context, l.savesBackupDone(file.path));
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  Future<void> _restore(File backup) async {
    final l = AppLocalizations.of(context)!;
    final version = ref.read(selectedVersionProvider);
    if (version == null) return;
    try {
      ref.read(saveServiceProvider).restore(version, backup);
      _reload();
      if (mounted) showInfo(context, l.savesRestoreDone);
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  void _delete(SaveEntry entry) {
    final l = AppLocalizations.of(context)!;
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l.savesDeleteConfirm(entry.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(
            onPressed: () {
              try {
                ref.read(saveServiceProvider).delete(entry);
                _reload();
              } catch (e, st) {
                showError(context, e, st);
              }
              Navigator.pop(context);
            },
            child: Text(l.delete),
          ),
        ],
      ),
    );
  }

  void _export(SaveEntry entry) {
    try {
      ref.read(saveServiceProvider).export(entry, _exportCtrl.text.trim());
      showInfo(context, _exportCtrl.text.trim());
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final version = ref.watch(selectedVersionProvider);
    final query = _searchCtrl.text.trim().toLowerCase();

    if (version == null) {
      return Scaffold(
        body: Center(child: EmptyState(icon: Icons.save_outlined, message: l.configNoVersion)),
      );
    }
    if (_watchedVersionId != version.id) {
      // Selected version changed elsewhere; rescan on next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
    }

    final entries = (_entries ?? const <SaveEntry>[])
        .where((e) => query.isEmpty || e.name.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      body: ListView(
        children: [
          PageHeader(
            title: l.savesTitle,
            actions: [
              Text(version.label),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: _backup,
                icon: const Icon(Icons.backup_outlined),
                label: Text(l.backup),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: l.savesSearchHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _importCtrl,
                    decoration: InputDecoration(hintText: l.savesImportPick),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _import,
                  child: Text(l.import),
                ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _exportCtrl,
                    decoration: const InputDecoration(hintText: 'D:\\export'),
                  ),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(icon: Icons.save_outlined, message: l.savesEmpty),
            ),
          for (final entry in entries)
            ListTile(
              leading: Icon(
                entry.group == 'autosave'
                    ? Icons.autorenew
                    : entry.group == 'scenarios'
                        ? Icons.map_outlined
                        : Icons.save_outlined,
              ),
              title: Text(entry.name),
              subtitle: Text(
                '${_groupLabel(l, entry.group)} · '
                '${formatBytes(entry.size)} · ${formatDateTime(entry.modified)}',
              ),
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: l.export,
                    icon: const Icon(Icons.file_upload_outlined),
                    onPressed: () => _export(entry),
                  ),
                  IconButton(
                    tooltip: l.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(entry),
                  ),
                ],
              ),
            ),
          PageHeader(
            title: l.savesBackups,
            actions: [
              TextButton(
                onPressed: () {
                  _reload();
                },
                child: Text(l.refresh),
              ),
            ],
          ),
          if (_backups == null || _backups!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyState(icon: Icons.backup_outlined, message: l.savesBackupsEmpty),
            ),
          for (final backup in _backups ?? const <File>[])
            ListTile(
              dense: true,
              leading: const Icon(Icons.backup_outlined),
              title: Text(backup.path.split(RegExp(r'[\\/]')).last),
              subtitle: Text(formatBytes(backup.lengthSync())),
              trailing: TextButton(
                onPressed: () => _restore(backup),
                child: Text(l.restore),
              ),
            ),
        ],
      ),
    );
  }
}
