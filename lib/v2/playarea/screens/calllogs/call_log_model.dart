import 'package:flutter/material.dart';

enum CallType {
  incoming(1, 'Incoming', Icons.call_received),
  outgoing(2, 'Outgoing', Icons.call_made),
  missed(3, 'Missed', Icons.call_missed),
  voicemail(4, 'Voicemail', Icons.voicemail),
  rejected(5, 'Rejected', Icons.call_end),
  blocked(6, 'Blocked', Icons.block),
  unknown(0, 'Unknown', Icons.call);

  final int value;
  final String label;
  final IconData icon;
  const CallType(this.value, this.label, this.icon);

  static CallType fromValue(int value) {
    return CallType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CallType.unknown,
    );
  }
}

class CallLogEntry {
  final String id;
  final String number;
  final String formattedNumber;
  final String name;
  final String normalizedNumber;
  final String countryIso;
  final String geoLocation;
  final DateTime date;
  final int duration;
  final CallType type;
  final String presentation;
  final String subscriptionComponentName;
  final String phoneAccountAddress;
  final String viaNumber;
  final String numberType;
  final String numberLabel;
  final String photoUri;
  final String lookupUri;
  final String postDialDigits;
  final String voicemailUri;
  final String transcription;
  final String transcriptionState;
  final String subject;
  final String priority;
  final String features;
  final String callScreeningAppName;
  final String callScreeningComponentName;
  final String assertedDisplayName;
  final String preferredDisplayName;
  final String blockReason;
  final String missedReason;
  final String composerPhotoUri;
  final String dataUsage;
  final String location;
  final String matchedNumber;
  final String uuid;
  final String lastModified;
  final String new_;
  final String isRead;
  final String isBusinessCall;
  final String isCallLogPhoneAccountMigrationPending;
  final String phoneAccountHidden;
  final String addForAllUsers;
  final String subscriptionId;
  final String photoId;
  final Map<String, String> raw;

  const CallLogEntry({
    required this.id,
    required this.number,
    required this.formattedNumber,
    required this.name,
    required this.normalizedNumber,
    required this.countryIso,
    required this.geoLocation,
    required this.date,
    required this.duration,
    required this.type,
    required this.presentation,
    required this.subscriptionComponentName,
    required this.phoneAccountAddress,
    required this.viaNumber,
    required this.numberType,
    required this.numberLabel,
    required this.photoUri,
    required this.lookupUri,
    required this.postDialDigits,
    required this.voicemailUri,
    required this.transcription,
    required this.transcriptionState,
    required this.subject,
    required this.priority,
    required this.features,
    required this.callScreeningAppName,
    required this.callScreeningComponentName,
    required this.assertedDisplayName,
    required this.preferredDisplayName,
    required this.blockReason,
    required this.missedReason,
    required this.composerPhotoUri,
    required this.dataUsage,
    required this.location,
    required this.matchedNumber,
    required this.uuid,
    required this.lastModified,
    required this.new_,
    required this.isRead,
    required this.isBusinessCall,
    required this.isCallLogPhoneAccountMigrationPending,
    required this.phoneAccountHidden,
    required this.addForAllUsers,
    required this.subscriptionId,
    required this.photoId,
    required this.raw,
  });

  String get displayName {
    if (name.isNotEmpty) return name;
    if (formattedNumber.isNotEmpty) return formattedNumber;
    if (number.isNotEmpty) return number;
    if (normalizedNumber.isNotEmpty) return normalizedNumber;
    return 'Unknown';
  }

  String get displayNumber {
    if (number.isNotEmpty) return number;
    if (normalizedNumber.isNotEmpty) return normalizedNumber;
    if (formattedNumber.isNotEmpty) return formattedNumber;
    return '';
  }

  factory CallLogEntry.fromMap(Map<String, String> map) {
    final dateMs = int.tryParse(map['date'] ?? '') ?? 0;
    final durationSec = int.tryParse(map['duration'] ?? '') ?? 0;
    final typeValue = int.tryParse(map['type'] ?? '') ?? 0;

    return CallLogEntry(
      id: map['_id'] ?? '',
      number: map['number'] ?? '',
      formattedNumber: map['formatted_number'] ?? '',
      name: map['name'] ?? '',
      normalizedNumber: map['normalized_number'] ?? '',
      countryIso: map['countryiso'] ?? '',
      geoLocation: map['geocoded_location'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      duration: durationSec,
      type: CallType.fromValue(typeValue),
      presentation: map['presentation'] ?? '',
      subscriptionComponentName: map['subscription_component_name'] ?? '',
      phoneAccountAddress: map['phone_account_address'] ?? '',
      viaNumber: map['via_number'] ?? '',
      numberType: map['numbertype'] ?? '',
      numberLabel: map['numberlabel'] ?? '',
      photoUri: map['photo_uri'] ?? '',
      lookupUri: map['lookup_uri'] ?? '',
      postDialDigits: map['post_dial_digits'] ?? '',
      voicemailUri: map['voicemail_uri'] ?? '',
      transcription: map['transcription'] ?? '',
      transcriptionState: map['transcription_state'] ?? '',
      subject: map['subject'] ?? '',
      priority: map['priority'] ?? '',
      features: map['features'] ?? '',
      callScreeningAppName: map['call_screening_app_name'] ?? '',
      callScreeningComponentName: map['call_screening_component_name'] ?? '',
      assertedDisplayName: map['asserted_display_name'] ?? '',
      preferredDisplayName: map['preferred_display_name'] ?? '',
      blockReason: map['block_reason'] ?? '',
      missedReason: map['missed_reason'] ?? '',
      composerPhotoUri: map['composer_photo_uri'] ?? '',
      dataUsage: map['data_usage'] ?? '',
      location: map['location'] ?? '',
      matchedNumber: map['matched_number'] ?? '',
      uuid: map['uuid'] ?? '',
      lastModified: map['last_modified'] ?? '',
      new_: map['new'] ?? '',
      isRead: map['is_read'] ?? '',
      isBusinessCall: map['is_business_call'] ?? '',
      isCallLogPhoneAccountMigrationPending:
          map['is_call_log_phone_account_migration_pending'] ?? '',
      phoneAccountHidden: map['phone_account_hidden'] ?? '',
      addForAllUsers: map['add_for_all_users'] ?? '',
      subscriptionId: map['subscription_id'] ?? '',
      photoId: map['photo_id'] ?? '',
      raw: Map<String, String>.from(map),
    );
  }
}
