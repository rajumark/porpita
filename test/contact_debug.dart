import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:porpita/services/content_query_parser.dart';
import 'package:porpita/v2/playarea/screens/contacts/contacts_service.dart';

const adbPath = '/Users/raju/Desktop/tools/platform-tools/adb';

void main() {
  test('Find all keys in first row', () async {
    final result = await Process.run(adbPath, [
      '-s', 'emulator-5554', 'shell', 'content', 'query', 
      '--uri', 'content://com.android.contacts/data'
    ]);
    final stdout = result.stdout.toString();
    final rows = ContentQueryParser.parse(
      stdout,
      knownColumns: kContactDataColumns,
    );
    
    final allKeys = <String>{};
    for (final r in rows.take(100)) {
      allKeys.addAll(r.keys);
    }
    final sortedKeys = allKeys.toList()..sort();
    for (final k in sortedKeys) {
      print(k);
    }
  });
}
