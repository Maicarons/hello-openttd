import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/mirror_config.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../ui/widgets/common.dart';

/// Launcher preferences: language, theme, mirrors, token, data root.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _tokenCtrl = TextEditingController();
  final _mirrorNameCtrl = TextEditingController();
  final _mirrorTemplateCtrl = TextEditingController();
  String? _probeResult;

  @override
  void initState() {
    super.initState();
    _tokenCtrl.text = ref.read(settingsProvider).githubToken;
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _mirrorNameCtrl.dispose();
    _mirrorTemplateCtrl.dispose();
    super.dispose();
  }

  void _openFolder(String path) {
    if (Platform.isWindows) {
      Process.run('explorer', [path]);
    } else if (Platform.isMacOS) {
      Process.run('open', [path]);
    } else {
      Process.run('xdg-open', [path]);
    }
  }

  Future<void> _probe() async {
    try {
      final results = await ref.read(mirrorServiceProvider).probeAll();
      final l = AppLocalizations.of(context)!;
      setState(() {
        _probeResult = [
          for (final e in results.entries)
            l.settingsProbeResult(e.key, e.value.inMilliseconds),
        ].join('\n');
      });
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  void _addMirror() {
    final l = AppLocalizations.of(context)!;
    final name = _mirrorNameCtrl.text.trim();
    final template = _mirrorTemplateCtrl.text.trim();
    if (name.isEmpty || template.isEmpty) return;
    try {
      // Validate early: template must yield an https URL.
      final sample = template.contains('{url}')
          ? template.replaceAll('{url}', 'https://github.com/x/y')
          : template;
      if (!sample.startsWith('https://')) throw const FormatException('https only');
      ref.read(mirrorsProvider.notifier).add(MirrorConfig(
            id: 'm${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            template: template,
          ));
      setState(() {
        _mirrorNameCtrl.clear();
        _mirrorTemplateCtrl.clear();
        _probeResult = null;
      });
      showInfo(context, l.settingsMirrorAdded);
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final mirrors = ref.watch(mirrorsProvider);
    final paths = ref.watch(appPathsProvider);
    final strategy = settings.mirrorStrategy;

    return Scaffold(
      body: ListView(
        children: [
          PageHeader(title: l.settingsTitle),
          _section(l.settingsGeneral),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.settingsLanguage),
            trailing: DropdownButton<String>(
              value: settings.locale,
              items: [
                DropdownMenuItem(value: 'system', child: Text(l.settingsLanguageSystem)),
                const DropdownMenuItem(value: 'zh', child: Text('简体中文')),
                const DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(locale: v ?? 'system'),
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(l.settingsTheme),
            trailing: DropdownButton<String>(
              value: settings.themeMode,
              items: [
                DropdownMenuItem(value: 'system', child: Text(l.settingsThemeSystem)),
                DropdownMenuItem(value: 'light', child: Text(l.settingsThemeLight)),
                DropdownMenuItem(value: 'dark', child: Text(l.settingsThemeDark)),
              ],
              onChanged: (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(themeMode: v ?? 'system'),
                  ),
            ),
          ),
          _section(l.settingsDownloads),
          ListTile(
            leading: const Icon(Icons.speed),
            title: Text(l.settingsMirrorStrategy),
            trailing: DropdownButton<String>(
              value: strategy,
              items: [
                DropdownMenuItem(value: 'auto', child: Text(l.settingsMirrorAuto)),
                DropdownMenuItem(value: 'fastest', child: Text(l.settingsMirrorFastest)),
                DropdownMenuItem(value: 'fixed', child: Text(l.settingsMirrorFixed)),
                DropdownMenuItem(value: 'official', child: Text(l.settingsMirrorOfficial)),
              ],
              onChanged: (v) => ref.read(settingsProvider.notifier).update(
                    (s) => s.copyWith(mirrorStrategy: v ?? 'auto'),
                  ),
            ),
          ),
          for (final mirror in mirrors)
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(mirror.name),
              subtitle: Text(mirror.template),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: mirror.enabled,
                    onChanged: (v) => ref.read(mirrorsProvider.notifier).update([
                      for (final m in mirrors)
                        if (m.id == mirror.id)
                          MirrorConfig(
                              id: m.id,
                              name: m.name,
                              template: m.template,
                              enabled: v,
                              weight: m.weight)
                        else
                          m,
                    ]),
                  ),
                  if (mirror.id != builtinDirectMirrorId)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref.read(mirrorsProvider.notifier).remove(mirror.id),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _mirrorNameCtrl,
                    decoration: InputDecoration(hintText: l.settingsMirrorName),
                  ),
                ),
                SizedBox(
                  width: 340,
                  child: TextField(
                    controller: _mirrorTemplateCtrl,
                    decoration: InputDecoration(
                        hintText: 'https://mirror.example/{url}'),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _addMirror,
                  child: Text(l.settingsAddMirror),
                ),
                TextButton.icon(
                  onPressed: _probe,
                  icon: const Icon(Icons.bolt),
                  label: Text(l.settingsProbeNow),
                ),
              ],
            ),
          ),
          if (_probeResult != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_probeResult!, style: Theme.of(context).textTheme.bodySmall),
            ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: Text(l.settingsGithubToken),
            subtitle: Text(l.settingsGithubTokenHint),
            trailing: SizedBox(
              width: 280,
              child: TextField(
                controller: _tokenCtrl,
                obscureText: true,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .update((s) => s.copyWith(githubToken: v)),
              ),
            ),
          ),
          _section(l.settingsDataRoot),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(paths.dataRoot.path),
            subtitle: Text(l.settingsPortable + (paths.portable ? ' ✓' : '')),
            trailing: TextButton.icon(
              onPressed: () => _openFolder(paths.dataRoot.path),
              icon: const Icon(Icons.folder_open),
              label: Text(l.settingsOpenDataRoot),
            ),
          ),
          _section(l.settingsAdvanced),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(l.settingsOpenLogs),
            trailing: TextButton(
              onPressed: () => _openFolder(paths.logsDir.path),
              child: Text(l.openFolder),
            ),
          ),
          _section(l.settingsAbout),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.settingsAboutBody, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );
}
