import 'contacts_service.dart';

class ContactsUri {
  final String label;
  final String uri;
  final List<String> columns;
  final bool isStandard;
  const ContactsUri({
    required this.label,
    required this.uri,
    required this.columns,
    this.isStandard = false,
  });
}

const List<ContactsUri> kContactsUris = [
  ContactsUri(
    label: 'Contacts',
    uri: 'content://com.android.contacts/contacts',
    columns: kContactColumns,
    isStandard: true,
  ),
  ContactsUri(
    label: 'Data',
    uri: 'content://com.android.contacts/data',
    columns: kContactDataColumns,
  ),
  ContactsUri(
    label: 'Raw Contacts',
    uri: 'content://com.android.contacts/raw_contacts',
    columns: kContactColumns,
  ),
  ContactsUri(
    label: 'Groups',
    uri: 'content://com.android.contacts/groups',
    columns: kContactColumns,
  ),
  ContactsUri(
    label: 'Status Updates',
    uri: 'content://com.android.contacts/status_updates',
    columns: kContactDataColumns,
  ),
  ContactsUri(
    label: 'Aggregation',
    uri: 'content://com.android.contacts/aggregation_exceptions',
    columns: kContactColumns,
  ),
];
