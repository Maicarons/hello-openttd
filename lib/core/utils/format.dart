/// Human-friendly byte sizes and durations (locale-neutral digits on purpose).
String formatBytes(int? bytes) {
  if (bytes == null) return '—';
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final text = value >= 100 || unit == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '$text ${units[unit]}';
}

String formatSpeed(double bytesPerSecond) =>
    '${formatBytes(bytesPerSecond.round())}/s';

String formatDateTime(DateTime? time) {
  if (time == null) return '—';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)} '
      '${two(time.hour)}:${two(time.minute)}';
}

/// Compares dotted version strings loosely ("1.2.10" > "1.2.9",
/// "0.61.2" vs "0.61"). Non-numeric suffixes are ignored for ordering.
int compareVersions(String a, String b) {
  List<int> parts(String v) => v
      .split(RegExp(r'[.\-+ ]'))
      .map((s) => int.tryParse(s) ?? 0)
      .toList();
  final pa = parts(a), pb = parts(b);
  final n = pa.length > pb.length ? pa.length : pb.length;
  for (var i = 0; i < n; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}
