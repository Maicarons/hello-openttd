/// One game launch (process) record persisted in `shared/runs.json`.
class RunRecord {
  RunRecord({
    required this.id,
    required this.versionId,
    required this.versionLabel,
    required this.mode,
    required this.args,
    required this.startedAt,
    this.exitedAt,
    this.exitCode,
    required this.logPath,
  });

  final String id;
  final String versionId;
  final String versionLabel;
  final String mode;
  final List<String> args;
  final DateTime startedAt;
  DateTime? exitedAt;
  int? exitCode;
  final String logPath;

  bool get running => exitedAt == null;

  factory RunRecord.fromJson(Map<String, dynamic> json) => RunRecord(
        id: json['id'] as String,
        versionId: json['versionId'] as String,
        versionLabel: (json['versionLabel'] as String?) ?? json['versionId'] as String,
        mode: (json['mode'] as String?) ?? 'newGame',
        args: (json['args'] as List?)?.cast<String>() ?? const [],
        startedAt: DateTime.parse(json['startedAt'] as String),
        exitedAt: json['exitedAt'] == null ? null : DateTime.parse(json['exitedAt'] as String),
        exitCode: (json['exitCode'] as num?)?.toInt(),
        logPath: json['logPath'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'versionId': versionId,
        'versionLabel': versionLabel,
        'mode': mode,
        'args': args,
        'startedAt': startedAt.toIso8601String(),
        'exitedAt': exitedAt?.toIso8601String(),
        'exitCode': exitCode,
        'logPath': logPath,
      };
}
