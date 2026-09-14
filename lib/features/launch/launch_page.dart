import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../data/models/run_record.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/service_providers.dart';
import '../../services/process/launch_options.dart';
import '../../ui/widgets/common.dart';

/// Launch page: mode selection, argument preview, run records.
class LaunchPage extends ConsumerStatefulWidget {
  const LaunchPage({super.key});

  @override
  ConsumerState<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends ConsumerState<LaunchPage> {
  LaunchMode _mode = LaunchMode.newGame;
  final _serverCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _resolutionCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();
  List<RunRecord> _records = [];
  StreamSubscription<RunExit>? _exitSub;

  @override
  void initState() {
    super.initState();
    _reload();
    _exitSub = ref.read(processServiceProvider).exits.listen((_) => _reload());
  }

  @override
  void dispose() {
    _exitSub?.cancel();
    _serverCtrl.dispose();
    _passwordCtrl.dispose();
    _resolutionCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _records = ref.read(processServiceProvider).records());
  }

  List<String> _buildArgs() {
    final version = ref.read(selectedVersionProvider);
    if (version == null) return const [];
    final paths = ref.read(appPathsProvider);
    return LaunchOptions.buildArguments(LaunchOptions(
      version: version,
      mode: _mode,
      sharedConfigPath:
          version.configMode == 'shared' ? paths.sharedConfigFile.path : null,
      savePath: _mode == LaunchMode.loadSave ? _serverCtrl.text.trim() : null,
      serverAddress: _mode == LaunchMode.joinServer || _mode == LaunchMode.dedicated
          ? _serverCtrl.text.trim()
          : null,
      serverPassword: _passwordCtrl.text.trim(),
      resolution: _resolutionCtrl.text.trim(),
      extraArgs: _extraCtrl.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toList(),
    ));
  }

  Future<void> _run() async {
    final version = ref.read(selectedVersionProvider);
    final l = AppLocalizations.of(context)!;
    if (version == null) return;
    final args = _buildArgs();
    try {
      if (version.configMode == 'shared') {
        final running = _records.any((r) => r.running);
        if (running) {
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(l.launchRunningWarningShared),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.ok)),
              ],
            ),
          );
          if (ok != true) return;
        }
      }
      await ref.read(processServiceProvider).start(version: version, args: args, mode: LaunchOptions.modeName(_mode));
      ref.read(versionsServiceProvider).updateLaunchStats(version);
      ref.read(installedVersionsProvider.notifier).refresh();
      _reload();
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  Future<void> _terminate(String runId) async {
    try {
      await ref.read(processServiceProvider).terminate(runId);
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  Future<void> _viewLog(String path) async {
    final content = _records.isEmpty ? '' : await _readLog(path);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(path),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: SelectableText(content.isEmpty ? '—' : content),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close)),
        ],
      ),
    );
  }

  Future<String> _readLog(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) return file.readAsStringSync();
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final version = ref.watch(selectedVersionProvider);
    final args = version == null ? const <String>[] : _buildArgs();

    return Scaffold(
      body: ListView(
        children: [
          PageHeader(title: l.launchTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(version?.label ?? l.homeNoVersions,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    // Full-width segmented control with per-segment flexible
                    // labels so it never overflows at the 1020px min width.
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final segmentWidth =
                            (constraints.maxWidth - 24) / 4;
                        return SegmentedButton<LaunchMode>(
                          segments: [
                            ButtonSegment(
                              value: LaunchMode.newGame,
                              label: SizedBox(
                                width: segmentWidth,
                                child: Text(l.launchModeNewGame, textAlign: TextAlign.center),
                              ),
                            ),
                            ButtonSegment(
                              value: LaunchMode.loadSave,
                              label: SizedBox(
                                width: segmentWidth,
                                child: Text(l.launchModeLoadSave, textAlign: TextAlign.center),
                              ),
                            ),
                            ButtonSegment(
                              value: LaunchMode.joinServer,
                              label: SizedBox(
                                width: segmentWidth,
                                child: Text(l.launchModeJoinServer, textAlign: TextAlign.center),
                              ),
                            ),
                            ButtonSegment(
                              value: LaunchMode.dedicated,
                              label: SizedBox(
                                width: segmentWidth,
                                child: Text(l.launchModeDedicated, textAlign: TextAlign.center),
                              ),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (s) => setState(() => _mode = s.first),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_mode == LaunchMode.loadSave)
                      TextField(
                        controller: _serverCtrl,
                        decoration: InputDecoration(labelText: l.launchSelectSave),
                      )
                    else if (_mode == LaunchMode.joinServer || _mode == LaunchMode.dedicated)
                      TextField(
                        controller: _serverCtrl,
                        decoration: InputDecoration(labelText: l.launchServerAddress),
                      ),
                    if (_mode == LaunchMode.joinServer) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(labelText: l.launchServerPassword),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _resolutionCtrl,
                          decoration: InputDecoration(labelText: l.launchResolution),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _extraCtrl,
                          decoration: InputDecoration(labelText: l.launchExtraArgs),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Text(l.launchPreview, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    SelectableText(
                      '${version == null ? '' : version.binaryPath} ${args.join(' ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: version == null ? null : _run,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l.launchRun),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PageHeader(title: l.launchRuns),
          if (_records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyState(icon: Icons.history, message: l.launchNoRuns),
            ),
          for (final record in _records.take(30))
            ListTile(
              leading: Icon(
                record.running
                    ? Icons.circle
                    : record.exitCode == 0
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                color: record.running
                    ? Theme.of(context).colorScheme.primary
                    : record.exitCode == 0
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                size: 18,
              ),
              title: Text(record.versionLabel),
              subtitle: Text(
                '${formatDateTime(record.startedAt)} · '
                '${record.running ? l.launchRunRunning : l.launchRunExit(record.exitCode ?? 0)}',
              ),
              trailing: Wrap(
                children: [
                  TextButton(
                    onPressed: () => _viewLog(record.logPath),
                    child: Text(l.launchViewLog),
                  ),
                  if (record.running)
                    TextButton(
                      onPressed: () => _terminate(record.id),
                      child: Text(l.launchStop),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
