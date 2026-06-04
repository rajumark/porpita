import 'package:flutter/material.dart';

enum ContactMimetype {
  name('vnd.android.cursor.item/name', 'Name', Icons.person_outline),
  phone('vnd.android.cursor.item/phone_v2', 'Phones', Icons.phone_outlined),
  email('vnd.android.cursor.item/email_v2', 'Emails', Icons.email_outlined),
  postalAddress('vnd.android.cursor.item/postal-address_v2', 'Addresses', Icons.location_on_outlined),
  organization('vnd.android.cursor.item/organization', 'Organization', Icons.business_outlined),
  nickname('vnd.android.cursor.item/nickname', 'Nickname', Icons.tag),
  note('vnd.android.cursor.item/note', 'Notes', Icons.sticky_note_2_outlined),
  website('vnd.android.cursor.item/website', 'Websites', Icons.link),
  event('vnd.android.cursor.item/contact_event', 'Events', Icons.event_outlined),
  im('vnd.android.cursor.item/im', 'IM', Icons.chat_outlined),
  sipAddress('vnd.android.cursor.item/sip_address', 'SIP', Icons.call_made),
  groupMembership('vnd.android.cursor.item/group_membership', 'Groups', Icons.group_outlined),
  identity('vnd.android.cursor.item/identity', 'Identity', Icons.badge_outlined),
  photo('vnd.android.cursor.item/photo', 'Photo', Icons.image_outlined),
  other('', 'Other', Icons.dataset_outlined);

  final String mime;
  final String label;
  final IconData icon;
  const ContactMimetype(this.mime, this.label, this.icon);

  static ContactMimetype fromMime(String? m) {
    if (m == null) return ContactMimetype.other;
    for (final t in ContactMimetype.values) {
      if (t.mime == m) return t;
    }
    return ContactMimetype.other;
  }
}

class ContactEntry {
  final String id;
  final String displayName;
  final String displayNameAlt;
  final String sortKey;
  final String lookup;
  final String photoUri;
  final String photoThumbUri;
  final String phonebookLabel;
  final String phonebookLabelAlt;
  final String hasPhoneNumber;
  final String starred;
  final String timesContacted;
  final String lastTimeContacted;
  final String sendToVoicemail;
  final String pinned;
  final String contactLastUpdatedTimestamp;
  final String inVisibleGroup;
  final String isUserProfile;
  final String phoneticName;
  final String customRingtone;
  final Map<String, String> raw;

  const ContactEntry({
    required this.id,
    required this.displayName,
    required this.displayNameAlt,
    required this.sortKey,
    required this.lookup,
    required this.photoUri,
    required this.photoThumbUri,
    required this.phonebookLabel,
    required this.phonebookLabelAlt,
    required this.hasPhoneNumber,
    required this.starred,
    required this.timesContacted,
    required this.lastTimeContacted,
    required this.sendToVoicemail,
    required this.pinned,
    required this.contactLastUpdatedTimestamp,
    required this.inVisibleGroup,
    required this.isUserProfile,
    required this.phoneticName,
    required this.customRingtone,
    required this.raw,
  });

  String get name {
    if (displayName.isNotEmpty) return displayName;
    if (displayNameAlt.isNotEmpty) return displayNameAlt;
    if (sortKey.isNotEmpty) return sortKey;
    return 'Contact #$id';
  }

  String get initials {
    final n = name.trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
    }
    return n.characters.first.toUpperCase();
  }

  bool get isStarred => starred == '1';
  bool get hasPhone => hasPhoneNumber == '1';
  bool get isPinned => pinned == '1';

  factory ContactEntry.fromMap(Map<String, String> map) {
    return ContactEntry(
      id: map['_id'] ?? '',
      displayName: map['display_name'] ?? '',
      displayNameAlt: map['display_name_alt'] ?? '',
      sortKey: map['sort_key'] ?? '',
      lookup: map['lookup'] ?? '',
      photoUri: map['photo_uri'] ?? '',
      photoThumbUri: map['photo_thumb_uri'] ?? '',
      phonebookLabel: map['phonebook_label'] ?? '',
      phonebookLabelAlt: map['phonebook_label_alt'] ?? '',
      hasPhoneNumber: map['has_phone_number'] ?? '',
      starred: map['starred'] ?? '',
      timesContacted: map['times_contacted'] ?? '',
      lastTimeContacted: map['last_time_contacted'] ?? '',
      sendToVoicemail: map['send_to_voicemail'] ?? '',
      pinned: map['pinned'] ?? '',
      contactLastUpdatedTimestamp: map['contact_last_updated_timestamp'] ?? '',
      inVisibleGroup: map['in_visible_group'] ?? '',
      isUserProfile: map['is_user_profile'] ?? '',
      phoneticName: map['phonetic_name'] ?? '',
      customRingtone: map['custom_ringtone'] ?? '',
      raw: Map<String, String>.from(map),
    );
  }
}

class ContactDataEntry {
  final String id;
  final String contactId;
  final String rawContactId;
  final String mimetype;
  final Map<String, String> dataFields;
  final String isPrimary;
  final String isSuperPrimary;
  final String dataVersion;
  final String hashId;
  final Map<String, String> raw;

  const ContactDataEntry({
    required this.id,
    required this.contactId,
    required this.rawContactId,
    required this.mimetype,
    required this.dataFields,
    required this.isPrimary,
    required this.isSuperPrimary,
    required this.dataVersion,
    required this.hashId,
    required this.raw,
  });

  ContactMimetype get type => ContactMimetype.fromMime(mimetype);

  String get primaryValue {
    switch (type) {
      case ContactMimetype.name:
        return dataFields['data1'] ?? '';
      case ContactMimetype.phone:
        return dataFields['data1'] ?? '';
      case ContactMimetype.email:
        return dataFields['data1'] ?? '';
      case ContactMimetype.nickname:
        return dataFields['data1'] ?? '';
      case ContactMimetype.note:
        return dataFields['data1'] ?? '';
      case ContactMimetype.website:
        return dataFields['data1'] ?? '';
      case ContactMimetype.sipAddress:
        return dataFields['data1'] ?? '';
      case ContactMimetype.im:
        return dataFields['data1'] ?? '';
      case ContactMimetype.identity:
        return dataFields['data1'] ?? '';
      case ContactMimetype.organization:
        return dataFields['data1'] ?? '';
      case ContactMimetype.postalAddress:
        return dataFields['data1'] ?? '';
      case ContactMimetype.event:
        return dataFields['data1'] ?? '';
      case ContactMimetype.groupMembership:
        return dataFields['data1'] ?? '';
      case ContactMimetype.photo:
        return dataFields['data15'] ?? '';
      case ContactMimetype.other:
        return dataFields['data1'] ?? '';
    }
  }

  String get secondaryValue {
    switch (type) {
      case ContactMimetype.phone:
        return dataFields['data2'] ?? '';
      case ContactMimetype.email:
        return dataFields['data2'] ?? '';
      case ContactMimetype.organization:
        return dataFields['data4'] ?? '';
      case ContactMimetype.event:
        return dataFields['data2'] ?? '';
      case ContactMimetype.im:
        return dataFields['data2'] ?? '';
      case ContactMimetype.postalAddress:
        return [
          dataFields['data4'] ?? '',
          dataFields['data7'] ?? '',
          dataFields['data8'] ?? '',
          dataFields['data9'] ?? '',
          dataFields['data10'] ?? '',
        ].where((s) => s.isNotEmpty).join(', ');
      default:
        return '';
    }
  }

  factory ContactDataEntry.fromMap(Map<String, String> map) {
    final dataFields = <String, String>{};
    for (int i = 1; i <= 15; i++) {
      final key = 'data$i';
      if (map.containsKey(key)) {
        dataFields[key] = map[key] ?? '';
      }
    }
    return ContactDataEntry(
      id: map['_id'] ?? '',
      contactId: map['contact_id'] ?? '',
      rawContactId: map['raw_contact_id'] ?? '',
      mimetype: map['mimetype'] ?? '',
      dataFields: dataFields,
      isPrimary: map['is_primary'] ?? '',
      isSuperPrimary: map['is_super_primary'] ?? '',
      dataVersion: map['data_version'] ?? '',
      hashId: map['hash_id'] ?? '',
      raw: Map<String, String>.from(map),
    );
  }
}
