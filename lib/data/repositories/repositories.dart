import 'dart:io';

import '../models/launcher_settings.dart';
import '../models/mirror_config.dart';
import '../models/run_record.dart';
import 'json_store.dart';

/// Read/write access to `<data-root>/settings.json`.
class SettingsRepository {
  SettingsRepository(this.file, {JsonStore store = const JsonStore()}) : _store = store;

  final File file;
  final JsonStore _store;

  LauncherSettings load() {
    final json = _store.read(file);
    if (json == null) return LauncherSettings();
    return LauncherSettings.fromJson(json);
  }

  void save(LauncherSettings settings) => _store.write(file, settings.toJson());
}

/// Read/write access to `<data-root>/mirrors.json`.
class MirrorsRepository {
  MirrorsRepository(this.file, {JsonStore store = const JsonStore()}) : _store = store;

  final File file;
  final JsonStore _store;

  List<MirrorConfig> load() {
    final json = _store.read(file);
    if (json == null) return defaultMirrors();
    final items = json['mirrors'] as List? ?? const [];
    return items.map((e) => MirrorConfig.fromJson(e as Map<String, dynamic>)).toList();
  }

  void save(List<MirrorConfig> mirrors) =>
      _store.write(file, {'schemaVersion': 1, 'mirrors': mirrors.map((m) => m.toJson()).toList()});
}

/// Rolling store of the last N run records.
class RunsRepository {
  RunsRepository(this.file, {JsonStore store = const JsonStore(), this.maxRecords = 200})
      : _store = store;

  final File file;
  final JsonStore _store;
  final int maxRecords;

  List<RunRecord> load() {
    final json = _store.read(file);
    if (json == null) return [];
    final items = json['runs'] as List? ?? const [];
    return items.map((e) => RunRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  void save(List<RunRecord> runs) {
    final trimmed = runs.length > maxRecords ? runs.sublist(runs.length - maxRecords) : runs;
    _store.write(file, {
      'schemaVersion': 1,
      'runs': trimmed.map((r) => r.toJson()).toList(),
    });
  }

  void append(RunRecord record) {
    final runs = load()..add(record);
    save(runs);
  }

  void update(RunRecord record) {
    final runs = load();
    final index = runs.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      runs[index] = record;
      save(runs);
    }
  }
}
