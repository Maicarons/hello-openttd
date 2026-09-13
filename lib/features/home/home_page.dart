import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../data/models/run_record.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/service_providers.dart';
import '../../ui/widgets/common.dart';

/// Home deck: quick stats, version selector and one-click launch.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<RunRecord> _records = [];
  StreamSubscription<RunExit>? _exitSub;

  @override
  void initState() {
    super.initState();
    _reload();
    _exitSub = ref.read(processServiceProvider).exits.listen((_) => _reload());
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _records = ref.read(processServiceProvider).records());
  }

  @override
  void dispose() {
    _exitSub?.cancel();
    super.dispose();
  }

  Future<void> _launch() async {
    final version = ref.read(selectedVersionProvider);
    if (version == null) return;
    try {
      await ref.read(processServiceProvider).start(
            version: version,
            args: const ['-g'],
            mode: 'newGame',
          );
      ref.read(versionsServiceProvider).updateLaunchStats(version);
      ref.read(installedVersionsProvider.notifier).refresh();
      _reload();
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final versionsAsync = ref.watch(installedVersionsProvider);
    final selected = ref.watch(selectedVersionProvider);
    final versions = versionsAsync.value ?? const [];
    final records = _records;

    return Scaffold(
      body: ListView(
        children: [
          PageHeader(title: l.homeTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatCard(
                  label: l.homeStatsVersions,
                  value: '${versions.length}',
                  icon: Icons.inventory_2_outlined,
                ),
                StatCard(
                  label: l.homeStatsRuns,
                  value: '${records.length}',
                  icon: Icons.play_circle_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (versions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                message: l.homeNoVersions,
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.homeSelectVersion,
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selected?.id,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.inventory_2_outlined),
                          hintText: l.homeSelectVersion,
                        ),
                        items: [
                          for (final v in versions)
                            DropdownMenuItem(value: v.id, child: Text(v.label)),
                        ],
                        onChanged: (id) =>
                            ref.read(selectedVersionIdProvider.notifier).select(id),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: selected == null ? null : _launch,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l.homeLaunch),
                      ),
                      if (selected?.lastLaunchedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.homeLastLaunched(formatDateTime(selected!.lastLaunchedAt)),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            PageHeader(title: l.homeRecentRuns),
            for (final record in records.take(8))
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
                trailing: Text(record.mode),
              ),
          ],
        ],
      ),
    );
  }
}
