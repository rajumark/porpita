String formatMessageTime(DateTime date) {
  if (date.millisecondsSinceEpoch <= 0) return '—';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final msgDay = DateTime(date.year, date.month, date.day);

  final hour12 = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
  final period = date.hour < 12 ? 'AM' : 'PM';
  final minuteStr = date.minute.toString().padLeft(2, '0');
  final timeStr = '$hour12:$minuteStr $period';

  if (msgDay == today) return 'Today $timeStr';
  if (msgDay == yesterday) return 'Yesterday $timeStr';

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
