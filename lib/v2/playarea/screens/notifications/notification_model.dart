import 'package:flutter/material.dart';

enum NotificationImportance {
  none(0, 'None', Icons.notifications_off),
  min(1, 'Min', Icons.notifications_paused),
  low(2, 'Low', Icons.notifications),
  default_(3, 'Default', Icons.notifications_active),
  high(4, 'High', Icons.priority_high),
  max(5, 'Max', Icons.notification_important);

  final int value;
  final String label;
  final IconData icon;
  const NotificationImportance(this.value, this.label, this.icon);

  static NotificationImportance fromValue(int value) {
    return NotificationImportance.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationImportance.none,
    );
  }

  static NotificationImportance fromLabel(String label) {
    return NotificationImportance.values.firstWhere(
      (e) => e.label.toUpperCase() == label.toUpperCase(),
      orElse: () => NotificationImportance.none,
    );
  }
}

class NotificationEntry {
  final String packageName;
  final String id;
  final String tag;
  final int importance;
  final String key;
  final String uid;
  final String userId;
  final String opPkg;
  final String flags;
  final String title;
  final String text;
  final String bigText;
  final String substName;
  final String channel;
  final String channelId;
  final String channelName;
  final DateTime when;
  final bool seen;
  final String importanceLabel;
  final List<String> actionLabels;
  final String groupKey;
  final String iconPkg;
  final String color;
  final String visibility;
  final String template;
  final Map<String, String> raw;

  const NotificationEntry({
    required this.packageName,
    required this.id,
    required this.tag,
    required this.importance,
    required this.key,
    required this.uid,
    required this.userId,
    required this.opPkg,
    required this.flags,
    required this.title,
    required this.text,
    required this.bigText,
    required this.substName,
    required this.channel,
    required this.channelId,
    required this.channelName,
    required this.when,
    required this.seen,
    required this.importanceLabel,
    required this.actionLabels,
    required this.groupKey,
    required this.iconPkg,
    required this.color,
    required this.visibility,
    required this.template,
    required this.raw,
  });

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (substName.isNotEmpty) return substName;
    return packageName;
  }

  String get displayText {
    if (text.isNotEmpty) return text;
    if (bigText.isNotEmpty) return bigText;
    return '';
  }

  String get displayApp {
    if (substName.isNotEmpty) return substName;
    return packageName;
  }

  NotificationImportance get importanceLevel =>
      NotificationImportance.fromValue(importance);

  Color importanceColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (importanceLevel) {
      case NotificationImportance.high:
      case NotificationImportance.max:
        return scheme.error;
      case NotificationImportance.default_:
        return scheme.primary;
      case NotificationImportance.low:
      case NotificationImportance.min:
        return scheme.onSurfaceVariant;
      case NotificationImportance.none:
        return scheme.outline;
    }
  }
}