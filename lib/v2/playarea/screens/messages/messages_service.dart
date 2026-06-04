import 'package:porpita/services/content_query_parser.dart';
import 'sms_model.dart';
import 'mms_model.dart';
import 'message_uri.dart';
import 'raw_message_entry.dart';

class MessagesService {
  static Future<List<SmsEntry>> fetchSms(String deviceId) async {
    final rows = await ContentQueryParser.query(
      deviceId: deviceId,
      uri: 'content://sms',
      knownColumns: kSmsColumns,
    );
    final list = rows.map(SmsEntry.fromMap).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static Future<List<MmsEntry>> fetchMms(String deviceId) async {
    final rows = await ContentQueryParser.query(
      deviceId: deviceId,
      uri: 'content://mms',
      knownColumns: kMmsColumns,
    );
    final list = rows.map(MmsEntry.fromMap).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static Future<List<SmsEntry>> fetchSmsByUri(
    String deviceId,
    MessageUri msgUri,
  ) async {
    final rows = await ContentQueryParser.query(
      deviceId: deviceId,
      uri: msgUri.uri,
      knownColumns: msgUri.columns,
    );
    final list = rows.map(SmsEntry.fromMap).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static Future<List<MmsEntry>> fetchMmsByUri(
    String deviceId,
    MessageUri msgUri,
  ) async {
    final rows = await ContentQueryParser.query(
      deviceId: deviceId,
      uri: msgUri.uri,
      knownColumns: msgUri.columns,
    );
    final list = rows.map(MmsEntry.fromMap).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static Future<List<RawMessageEntry>> fetchRawByUri(
    String deviceId,
    MessageUri msgUri,
  ) async {
    final rows = await ContentQueryParser.query(
      deviceId: deviceId,
      uri: msgUri.uri,
      knownColumns: msgUri.columns,
    );
    return rows.map(RawMessageEntry.new).toList();
  }
}
