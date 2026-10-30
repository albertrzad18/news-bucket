/// Short relative time such as "5m", "3h", "2d", or a date for older items.
String timeAgo(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).toUtc().difference(time.toUtc());
  if (diff.isNegative || diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 30) return '${diff.inDays}d';
  final local = time.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
