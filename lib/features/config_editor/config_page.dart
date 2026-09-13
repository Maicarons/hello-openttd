import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/service_providers.dart';
import '../../services/config/cfg_document.dart';
import '../../services/config/key_catalog.dart';
import '../../ui/widgets/common.dart';

/// Graphical openttd.cfg editor: typed forms for cataloged keys, raw text
/// for everything else; saves create timestamped .bak files.
class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  CfgDocument? _doc;
  final _rawController = TextEditingController();
  final _searchController = TextEditingController();
  bool _rawMode = false;

  @override
  void dispose() {
    _rawController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadDoc() {
    final version = ref.read(selectedVersionProvider);
    if (version == null) return;
    final doc = ref.read(cfgServiceProvider).load(version);
    setState(() {
      _doc = doc;
      _rawController.text = doc.serialize();
    });
  }

  void _setCatalogValue(CatalogEntry entry, String value) {
    _doc?.setValue(entry.section, entry.key, value);
    setState(() => _rawController.text = _doc!.serialize());
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final version = ref.read(selectedVersionProvider);
    if (version == null || _doc == null) return;
    // Raw-mode edits win when the user was in the raw tab.
    if (_rawMode) {
      _doc = CfgDocument.parse(_rawController.text);
    }
    try {
      final backup = ref.read(cfgServiceProvider).save(version, _doc!);
      if (!mounted) return;
      showInfo(context, backup == null
          ? l.configSavedNoBackup
          : l.configSaved(backup.split(RegExp(r'[\\/]')).last));
    } catch (e, st) {
      showError(context, e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final version = ref.watch(selectedVersionProvider);

    if (version == null) {
      return Scaffold(
        body: Center(child: EmptyState(icon: Icons.tune, message: l.configNoVersion)),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          PageHeader(
            title: l.configTitle,
            actions: [
              Text(version.label),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(l.save),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l.configFormView)),
                ButtonSegment(value: true, label: Text(l.configRawView)),
              ],
              selected: {_rawMode},
              onSelectionChanged: (s) => setState(() {
                _rawMode = s.first;
                if (!_rawMode && _doc != null) {
                  // Reload from raw edits so the form reflects them.
                  _doc = CfgDocument.parse(_rawController.text);
                }
              }),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.configSaveHint, style: Theme.of(context).textTheme.bodySmall),
          ),
          if (_doc == null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: _loadDoc,
                    child: Text(l.refresh),
                  ),
                ],
              ),
            )
          else if (_rawMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 520,
                child: TextField(
                  controller: _rawController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            )
          else
            _FormView(
              doc: _doc!,
              search: _searchController,
              onSearch: () => setState(() {}),
              onSet: _setCatalogValue,
            ),
        ],
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.doc,
    required this.search,
    required this.onSearch,
    required this.onSet,
  });

  final CfgDocument doc;
  final TextEditingController search;
  final VoidCallback onSearch;
  final void Function(CatalogEntry, String) onSet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    final query = search.text.trim().toLowerCase();

    final catalog = keyCatalog
        .map((e) => (entry: e, current: doc.value(e.section, e.key)))
        .where((e) =>
            query.isEmpty ||
            e.entry.key.toLowerCase().contains(query) ||
            (isZh ? e.entry.docZh : e.entry.docEn).toLowerCase().contains(query))
        .toList();

    final catalogedKeys = keyCatalog.map((e) => '${e.section}.${e.key}').toSet();
    final others = <(String, String, String)>[];
    for (final section in doc.sectionNames) {
      for (final line in doc.entriesIn(section)) {
        final id = '${line.section ?? ''}.${line.key}';
        if (!catalogedKeys.contains(id)) {
          others.add((line.section ?? '', line.key, line.value));
        }
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: search,
            decoration: InputDecoration(
              hintText: l.configSearchHint,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => onSearch(),
          ),
        ),
        const SizedBox(height: 8),
        for (final (:entry, :current) in catalog)
          Card(
            child: ListTile(
              title: Text(isZh ? entry.labelZh : entry.labelEn),
              subtitle: Text(
                '${entry.section} · ${entry.key}\n'
                '${isZh ? entry.docZh : entry.docEn}',
              ),
              isThreeLine: true,
              trailing: SizedBox(
                width: 200,
                child: _entryControl(entry, current, context),
              ),
            ),
          ),
        if (others.isNotEmpty) ...[
          PageHeader(title: l.configOtherKeys),
          for (final (section, key, value) in others.take(80))
            ListTile(
              dense: true,
              title: Text('$section · $key'),
              subtitle: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
      ],
    );
  }

  Widget _entryControl(CatalogEntry entry, String? current, BuildContext context) {
    switch (entry.type) {
      case CatalogType.bool_:
        final value = current?.toLowerCase() == 'true';
        return SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: value,
          onChanged: (v) => onSet(entry, v ? 'true' : 'false'),
        );
      case CatalogType.enum_:
        return DropdownButtonFormField<String>(
          initialValue: current,
          items: [
            for (final o in entry.options)
              DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) {
            if (v != null) onSet(entry, v);
          },
        );
      case CatalogType.int_:
        return TextFormField(
          initialValue: current,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '${entry.min ?? 0}–${entry.max ?? 9999}',
          ),
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null &&
                (entry.min == null || n >= entry.min!) &&
                (entry.max == null || n <= entry.max!)) {
              onSet(entry, n.toString());
            }
          },
        );
      case CatalogType.string:
        return TextFormField(
          initialValue: current ?? '',
          onChanged: (v) => onSet(entry, v),
        );
    }
  }
}
