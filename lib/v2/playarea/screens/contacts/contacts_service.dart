import 'dart:io';

import 'package:porpita/services/adb_manager.dart';
import 'package:porpita/services/content_query_parser.dart';
import 'contact_model.dart';

const List<String> kContactColumns = [
  '_id',
  'display_name',
  'display_name_alt',
  'sort_key',
  'sort_key_alt',
  'lookup',
  'photo_uri',
  'photo_thumb_uri',
  'phonebook_label',
  'phonebook_label_alt',
  'has_phone_number',
  'starred',
  'times_contacted',
  'last_time_contacted',
  'send_to_voicemail',
  'pinned',
  'contact_last_updated_timestamp',
  'in_visible_group',
  'is_user_profile',
  'phonetic_name',
  'phonetic_name_style',
  'custom_ringtone',
  'phonebook_bucket',
  'phonebook_bucket_alt',
  'in_default_directory',
  'name_raw_contact_id',
  'display_name_source',
];

const List<String> kContactDataColumns = [
  '_id',
  'contact_id',
  'raw_contact_id',
  'mimetype',
  'is_primary',
  'is_super_primary',
  'data_version',
  'hash_id',
  'data1', 'data2', 'data3', 'data4', 'data5',
  'data6', 'data7', 'data8', 'data9', 'data10',
  'data11', 'data12', 'data13', 'data14', 'data15',
  'display_name',
  'sort_key',
  'phonetic_name',
  'status_res_package',
  'custom_ringtone',
  'contact_status_ts',
  'account_type',
  'photo_file_id',
  'contact_status_res_package',
  'group_sourceid',
  'display_name_alt',
  'sort_key_alt',
  'mode',
  'last_time_used',
  'starred',
  'contact_status_label',
  'has_phone_number',
  'chat_capability',
  'carrier_presence',
  'contact_last_updated_timestamp',
  'res_package',
  'photo_uri',
  'data_sync1', 'data_sync2', 'data_sync3', 'data_sync4',
  'phonebook_bucket',
  'times_used',
  'version',
  'photo_thumb_uri',
  'status_label',
  'contact_presence',
  'in_default_directory',
  'times_contacted',
  'account_type_and_data_set',
  'name_raw_contact_id',
  'status',
  'phonebook_bucket_alt',
  'last_time_contacted',
  'pinned',
  'photo_id',
  'contact_chat_capability',
  'contact_status_icon',
  'in_visible_group',
  'phonebook_label',
  'account_name',
  'display_name_source',
  'dirty',
  'sourceid',
  'phonetic_name_style',
  'send_to_voicemail',
  'lookup',
  'data_set',
  'contact_status',
  'backup_id',
  'preferred_phone_account_component_name',
  'raw_contact_is_user_profile',
  'status_ts',
  'preferred_phone_account_id',
  'status_icon',
];

class ContactDetails {
  final ContactEntry? summary;
  final List<ContactDataEntry> dataRows;
  final String? error;

  const ContactDetails({
    this.summary,
    required this.dataRows,
    this.error,
  });

  bool get isEmpty => summary == null && dataRows.isEmpty;

  List<ContactDataEntry> byType(ContactMimetype t) =>
      dataRows.where((d) => d.type == t).toList();

  ContactDataEntry? get primaryName {
    final names = byType(ContactMimetype.name);
    if (names.isEmpty) return null;
    return names.firstWhere(
      (n) => n.isSuperPrimary == '1',
      orElse: () => names.first,
    );
  }

  List<ContactDataEntry> get phones => byType(ContactMimetype.phone);
  List<ContactDataEntry> get emails => byType(ContactMimetype.email);
  List<ContactDataEntry> get addresses => byType(ContactMimetype.postalAddress);
  List<ContactDataEntry> get organizations => byType(ContactMimetype.organization);
  List<ContactDataEntry> get notes => byType(ContactMimetype.note);
  List<ContactDataEntry> get websites => byType(ContactMimetype.website);
  List<ContactDataEntry> get events => byType(ContactMimetype.event);
  List<ContactDataEntry> get ims => byType(ContactMimetype.im);
  List<ContactDataEntry> get sips => byType(ContactMimetype.sipAddress);
  List<ContactDataEntry> get nicknames => byType(ContactMimetype.nickname);
  List<ContactDataEntry> get groups => byType(ContactMimetype.groupMembership);
  List<ContactDataEntry> get identities => byType(ContactMimetype.identity);
}

class ContactsService {
  static const _contactsUri = 'content://com.android.contacts/contacts';
  static const _dataUri = 'content://com.android.contacts/data';

  static Future<List<ContactEntry>> fetchContacts(String deviceId) async {
    final rows = await ContentQueryParser.query(
      deviceId: deviceId,
      uri: _contactsUri,
      knownColumns: kContactColumns,
    );
    final list = rows.map(ContactEntry.fromMap).toList();
    list.sort((a, b) {
      final ai = int.tryParse(a.id) ?? 0;
      final bi = int.tryParse(b.id) ?? 0;
      return bi.compareTo(ai);
    });
    return list;
  }

  static Future<ContactDetails> fetchContactDetails(
    String deviceId,
    String contactId,
  ) async {
    try {
      final summaryRows = await ContentQueryParser.query(
        deviceId: deviceId,
        uri: '$_contactsUri/$contactId',
        knownColumns: kContactColumns,
      );

      final dataRows = await _queryDataForContact(deviceId, contactId);

      return ContactDetails(
        summary: summaryRows.isNotEmpty
            ? ContactEntry.fromMap(summaryRows.first)
            : null,
        dataRows: dataRows,
      );
    } catch (e) {
      return ContactDetails(
        summary: null,
        dataRows: const [],
        error: e.toString(),
      );
    }
  }

  static Future<List<ContactDataEntry>> _queryDataForContact(
    String deviceId,
    String contactId,
  ) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return [];
    final safeId = contactId.replaceAll("'", "''");
    final result = await Process.run(adb, [
      '-s', deviceId, 'shell', 'content', 'query',
      '--uri', _dataUri,
      '--where', "'contact_id=''$safeId'''",
    ]);
    if (result.exitCode != 0) return [];
    final rows = ContentQueryParser.parse(
      result.stdout.toString(),
      knownColumns: kContactDataColumns,
    );
    return rows.map(ContactDataEntry.fromMap).toList();
  }

  static Future<ContactDetails> fetchContactDetailsByNumber(
    String deviceId,
    String phoneNumber,
  ) async {
    final sanitized = _sanitize(phoneNumber);
    if (sanitized.isEmpty) {
      return const ContactDetails(dataRows: [], error: 'Empty number');
    }

    final candidates = <String>{
      phoneNumber,
      sanitized,
      sanitized.replaceFirst(RegExp(r'^\+'), ''),
      '+1$sanitized',
    }.where((s) => s.isNotEmpty).toList();

    final variations = <String>{};
    for (final c in candidates) {
      variations.add(c);
      final digitsOnly = c.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.isNotEmpty) variations.add(digitsOnly);
      if (digitsOnly.length >= 10) {
        variations.add(digitsOnly.substring(digitsOnly.length - 10));
      }
    }

    for (final candidate in variations) {
      final safe = candidate.replaceAll("'", "''");
      final where =
          "mimetype='vnd.android.cursor.item/phone_v2' AND data1='$safe'";
      try {
        final rows = await _queryWithWhere(deviceId, _dataUri, where);
        if (rows.isEmpty) continue;
        final contactId = rows.first['contact_id'];
        if (contactId == null || contactId.isEmpty) continue;
        return fetchContactDetails(deviceId, contactId);
      } catch (_) {
        continue;
      }
    }

    return const ContactDetails(dataRows: [], error: 'No contact found');
  }

  static String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static Future<List<Map<String, String>>> _queryWithWhere(
    String deviceId,
    String uri,
    String where,
  ) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return [];

    final quoted = "'${where.replaceAll("'", "'\\''")}'";
    final result = await Process.run(adb, [
      '-s', deviceId, 'shell', 'content', 'query',
      '--uri', uri,
      '--where', quoted,
    ]);
    if (result.exitCode != 0) return [];
    return ContentQueryParser.parse(
      result.stdout.toString(),
      knownColumns: kContactDataColumns,
    );
  }
}
