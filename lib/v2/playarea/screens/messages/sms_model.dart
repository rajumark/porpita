import 'package:flutter/material.dart';

enum MessageBox {
  all(0, 'All'),
  inbox(1, 'Inbox'),
  sent(2, 'Sent'),
  draft(3, 'Draft'),
  outbox(4, 'Outbox'),
  failed(5, 'Failed'),
  queued(6, 'Queued'),
  unknown(-1, 'Unknown');

  final int value;
  final String label;
  const MessageBox(this.value, this.label);

  static MessageBox fromValue(int v) =>
      MessageBox.values.firstWhere((e) => e.value == v, orElse: () => MessageBox.unknown);
}

class SmsEntry {
  final String id;
  final String threadId;
  final String address;
  final String person;
  final DateTime date;
  final DateTime dateSent;
  final String protocol;
  final String read;
  final String status;
  final MessageBox type;
  final String replyPathPresent;
  final String subject;
  final String body;
  final String serviceCenter;
  final String locked;
  final String subId;
  final String errorCode;
  final String creator;
  final String seen;
  final String containsOtp;
  final String trId;
  final String restricted;
  final Map<String, String> raw;

  const SmsEntry({
    required this.id,
    required this.threadId,
    required this.address,
    required this.person,
    required this.date,
    required this.dateSent,
    required this.protocol,
    required this.read,
    required this.status,
    required this.type,
    required this.replyPathPresent,
    required this.subject,
    required this.body,
    required this.serviceCenter,
    required this.locked,
    required this.subId,
    required this.errorCode,
    required this.creator,
    required this.seen,
    required this.containsOtp,
    required this.trId,
    required this.restricted,
    required this.raw,
  });

  bool get isIncoming => type == MessageBox.inbox;
  bool get isOutgoing => type == MessageBox.sent;
  bool get isUnread => read == '0';
  bool get hasOtp => containsOtp == '1';

  String get displayAddress {
    if (address.isEmpty) return 'Unknown';
    return address;
  }

  String get preview {
    final b = body.trim();
    if (b.isEmpty) return '(empty)';
    return b.length > 200 ? '${b.substring(0, 200)}…' : b;
  }

  IconData get directionIcon {
    if (isIncoming) return Icons.call_received;
    if (isOutgoing) return Icons.call_made;
    return Icons.message;
  }

  Color directionColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isIncoming) return Colors.green;
    if (isOutgoing) return scheme.primary;
    return scheme.outline;
  }

  factory SmsEntry.fromMap(Map<String, String> map) {
    final dateMs = int.tryParse(map['date'] ?? '') ?? 0;
    final dateSentMs = int.tryParse(map['date_sent'] ?? '') ?? 0;
    final typeInt = int.tryParse(map['type'] ?? '') ?? -1;

    return SmsEntry(
      id: map['_id'] ?? '',
      threadId: map['thread_id'] ?? '',
      address: map['address'] ?? '',
      person: map['person'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      dateSent: DateTime.fromMillisecondsSinceEpoch(dateSentMs),
      protocol: map['protocol'] ?? '',
      read: map['read'] ?? '',
      status: map['status'] ?? '',
      type: MessageBox.fromValue(typeInt),
      replyPathPresent: map['reply_path_present'] ?? '',
      subject: map['subject'] ?? '',
      body: map['body'] ?? '',
      serviceCenter: map['service_center'] ?? '',
      locked: map['locked'] ?? '',
      subId: map['sub_id'] ?? '',
      errorCode: map['error_code'] ?? '',
      creator: map['creator'] ?? '',
      seen: map['seen'] ?? '',
      containsOtp: map['contains_otp'] ?? '',
      trId: map['tr_id'] ?? '',
      restricted: map['restricted'] ?? '',
      raw: Map<String, String>.from(map),
    );
  }
}

const List<String> kSmsColumns = [
  '_id',
  'thread_id',
  'address',
  'person',
  'date',
  'date_sent',
  'protocol',
  'read',
  'status',
  'type',
  'reply_path_present',
  'subject',
  'body',
  'service_center',
  'locked',
  'sub_id',
  'error_code',
  'creator',
  'seen',
  'contains_otp',
  'tr_id',
  'restricted',
];
