/// A user-managed download mirror persisted in `mirrors.json`.
///
/// `template` uses `{url}` for prefix-style proxies
/// (`https://ghfast.net/{url}`); when `{url}` is absent the template may use
/// `{owner} {repo} {tag} {asset}` for rewrite-style mirrors.
class MirrorConfig {
  MirrorConfig({
    required this.id,
    required this.name,
    required this.template,
    this.enabled = true,
    this.weight = 5,
  });

  final String id;
  final String name;
  final String template;
  final bool enabled;
  final int weight;

  factory MirrorConfig.fromJson(Map<String, dynamic> json) => MirrorConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        template: json['template'] as String,
        enabled: (json['enabled'] as bool?) ?? true,
        weight: (json['weight'] as num?)?.toInt() ?? 5,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'template': template,
        'enabled': enabled,
        'weight': weight,
      };
}

/// Well-known built-in "mirrors".
///
/// Note: ghproxy.com is intentionally absent — the domain changed hands and
/// returns HTTP 200 HTML pages for every request, silently corrupting
/// downloads (lesson inherited from openttd-manager-plus).
const builtinDirectMirrorId = 'direct';

List<MirrorConfig> defaultMirrors() => [
      MirrorConfig(
        id: builtinDirectMirrorId,
        name: 'GitHub (direct)',
        template: '{url}',
        enabled: true,
        weight: 10,
      ),
      MirrorConfig(
        id: 'ghfast',
        name: 'ghfast.net',
        template: 'https://ghfast.net/{url}',
        enabled: true,
        weight: 5,
      ),
    ];
