import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/errors/failures.dart';
import '../../core/logging.dart';
import '../../core/paths/app_paths.dart';
import '../../data/models/run_record.dart';
import '../../data/models/version_manifest.dart' show VersionManifestLike;
import '../../data/repositories/repositories.dart';

/// Spawns and monitors game processes; every run gets a log file and a
/// persisted [RunRecord] (docs/dev/process).
class ProcessService {
  ProcessService({
    required this.paths,
    required RunsRepository runsRepository,
  }) : _runs = runsRepository;

  final AppPaths paths;
  final RunsRepository _runs;
  final Map<String, Process> _active = {};

  /// Fires when a run exits (runId, exitCode).
  final _exits = StreamController<RunExit>.broadcast();
  Stream<RunExit> get exits => _exits.stream;

  List<RunRecord> records() => _runs.load().reversed.toList();

  Future<RunRecord> start({
    required VersionManifestLike version,
    required List<String> args,
    required String mode,
  }) async {
    final binary = File(version.binaryPath);
    if (!binary.existsSync()) {
      throw NotFoundFailure('binary missing: ${version.binaryPath}');
    }
    final runId = 'r${DateTime.now().millisecondsSinceEpoch}';
    final runsDir = Directory(p.join(paths.logsDir.path, 'runs'));
    if (!runsDir.existsSync()) runsDir.createSync(recursive: true);
    final logFile = File(p.join(runsDir.path, '$runId.log'));

    final record = RunRecord(
      id: runId,
      versionId: version.id,
      versionLabel: version.label,
      mode: mode,
      args: args,
      startedAt: DateTime.now(),
      logPath: logFile.path,
    );

    final Process process;
    try {
      process = await Process.start(
        binary.path,
        args,
        workingDirectory: p.dirname(binary.path),
        mode: ProcessStartMode.normal,
      );
    } on ProcessException catch (e) {
      throw ProcessFailure('spawn failed: ${e.message}');
    }
    _active[runId] = process;
    _runs.append(record);

    _pipeToLog(process, logFile);
    unawaited(process.exitCode.then((code) {
      _active.remove(runId);
      record.exitedAt = DateTime.now();
      record.exitCode = code;
      _runs.update(record);
      _exits.add(RunExit(runId: runId, exitCode: code));
      Log.info('run $runId exited with $code');
    }));
    return record;
  }

  void _pipeToLog(Process process, File logFile) {
    final sink = logFile.openWrite();
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(sink.writeln, onDone: sink.close, onError: (_) => sink.close());
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(sink.writeln, onError: (_) {});
  }

  bool isRunning(String runId) => _active.containsKey(runId);

  Future<void> terminate(String runId) async {
    final process = _active[runId];
    if (process == null) return;
    process.kill();
    final exited = await process.exitCode
        .timeout(const Duration(seconds: 5), onTimeout: () => -1);
    if (exited == -1) {
      process.kill(ProcessSignal.sigkill);
    }
  }
}

class RunExit {
  RunExit({required this.runId, required this.exitCode});
  final String runId;
  final int exitCode;
}
