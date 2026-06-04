String formatCallLogTime(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final callDay = DateTime(date.year, date.month, date.day);

  final hour12 = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
  final period = date.hour < 12 ? 'AM' : 'PM';
  final minuteStr = date.minute.toString().padLeft(2, '0');
  final timeStr = '$hour12:$minuteStr $period';

  if (callDay == today) return 'Today $timeStr';
  if (callDay == yesterday) return 'Yesterday $timeStr';

  final monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final monthName = monthNames[date.month - 1];
  final sameYear = date.year == now.year;
  if (sameYear) {
    return '$monthName ${date.day} $timeStr';
  }
  return '$monthName ${date.day}, ${date.year} $timeStr';
}

String formatCallDuration(int seconds) {
  if (seconds <= 0) return '0s';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final parts = <String>[];
  if (h > 0) parts.add('${h}h');
  if (m > 0) parts.add('${m}m');
  if (s > 0 && h == 0) parts.add('${s}s');
  return parts.isEmpty ? '0s' : parts.join(' ');
}
