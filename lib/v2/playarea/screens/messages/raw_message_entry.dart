import 'sms_model.dart';
import 'mms_model.dart';

class RawMessageEntry {
  final Map<String, String> raw;
  const RawMessageEntry(this.raw);

  String get id => raw['_id'] ?? raw['thread_id'] ?? '';

  String get primaryText {
    for (final key in ['address', 'm_id', 'sub', 'name', 'person', 'name', 'fn', '_data']) {
      final v = raw[key];
      if (v != null && v.isNotEmpty) return v;
    }
    return id;
  }

  String get secondaryText {
    for (final key in ['body', 'text', 'name', 'ct', 'sub', 'ct_t', 'address', 'type']) {
      final v = raw[key];
      if (v != null && v.isNotEmpty && v != primaryText) return v;
    }
    return '';
  }

  DateTime? get date {
    final ms = int.tryParse(raw['date'] ?? '') ?? 0;
    if (ms <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get hasStandardSms {
    return raw.containsKey('body') && raw.containsKey('address');
  }

  SmsEntry? toSms() {
    if (!hasStandardSms) return null;
    try {
      return SmsEntry.fromMap(raw);
    } catch (_) {
      return null;
    }
  }

  MmsEntry? toMms() {
    if (raw['msg_box'] == null && raw['m_id'] == null) return null;
    try {
      return MmsEntry.fromMap(raw);
    } catch (_) {
      return null;
    }
  }
}
