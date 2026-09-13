/// Typed failures crossing service boundaries. UI maps [kind] to localized
/// copy; technical detail stays in [detail]/logs.
sealed class Failure implements Exception {
  Failure(this.kind, this.detail);

  final FailureKind kind;
  final String detail;

  @override
  String toString() => '$Failure(${kind.name}): $detail';
}

enum FailureKind {
  network,
  timeout,
  checksum,
  path,
  disk,
  parse,
  urlInvalid,
  process,
  notFound,
  conflict,
  cancelled,
  unknown,
}

class NetworkFailure extends Failure {
  NetworkFailure(String detail) : super(FailureKind.network, detail);
}

class TimeoutFailure extends Failure {
  TimeoutFailure(String detail) : super(FailureKind.timeout, detail);
}

class ChecksumFailure extends Failure {
  ChecksumFailure({required this.expected, required this.actual})
      : super(FailureKind.checksum, 'sha256 expected=$expected actual=$actual');
  final String expected;
  final String actual;
}

class PathGuardFailure extends Failure {
  PathGuardFailure(String detail) : super(FailureKind.path, detail);
}

class DiskFailure extends Failure {
  DiskFailure(String detail) : super(FailureKind.disk, detail);
}

class ParseFailure extends Failure {
  ParseFailure(String detail) : super(FailureKind.parse, detail);
}

class UrlInvalidFailure extends Failure {
  UrlInvalidFailure(String detail) : super(FailureKind.urlInvalid, detail);
}

class ProcessFailure extends Failure {
  ProcessFailure(String detail, {this.exitCode, this.logTail})
      : super(FailureKind.process, detail);
  final int? exitCode;
  final String? logTail;
}

class NotFoundFailure extends Failure {
  NotFoundFailure(String detail) : super(FailureKind.notFound, detail);
}

class ConflictFailure extends Failure {
  ConflictFailure(String detail) : super(FailureKind.conflict, detail);
}

class CancelledFailure extends Failure {
  CancelledFailure([String detail = 'cancelled'])
      : super(FailureKind.cancelled, detail);
}

class UnknownFailure extends Failure {
  UnknownFailure(String detail) : super(FailureKind.unknown, detail);
}

/// Maps arbitrary exceptions into [Failure] — the only crossing point.
Failure asFailure(Object error) {
  if (error is Failure) return error;
  return UnknownFailure(error.toString());
}
