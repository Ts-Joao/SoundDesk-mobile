String fmtDuration(Duration d) {
  final m = d.inMinutes, s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String fmtMb(int bytes) => '${(bytes / 1048576).toStringAsFixed(1)} MB';

String fmtAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inDays >= 1) return 'há ${d.inDays} ${d.inDays == 1 ? 'dia' : 'dias'}';
  if (d.inHours >= 1) return 'há ${d.inHours} h';
  return 'agora há pouco';
}
