import 'sms_model.dart';
import 'mms_model.dart';

const List<String> kAllMessageColumns = [
  ...kSmsColumns,
  ...kMmsColumns,
  ...kMmsPartColumns,
  ...kMmsAddrColumns,
  'recipient_ids',
  'type',
  'msg_id',
  'contact_id',
  'charset',
  'mid',
  'seq',
  'chset',
  'cd',
  'fn',
  'cid',
  'cl',
  'ctt_s',
  '_data',
];

class MessageUri {
  final String label;
  final String uri;
  final List<String> columns;
  final bool isStandard;

  const MessageUri({
    required this.label,
    required this.uri,
    required this.columns,
    this.isStandard = false,
  });
}

const List<MessageUri> kSmsUris = [
  MessageUri(
    label: 'All',
    uri: 'content://sms',
    columns: kSmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Inbox',
    uri: 'content://sms/inbox',
    columns: kSmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Sent',
    uri: 'content://sms/sent',
    columns: kSmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Draft',
    uri: 'content://sms/draft',
    columns: kSmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Outbox',
    uri: 'content://sms/outbox',
    columns: kSmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Conversations',
    uri: 'content://sms/conversations',
    columns: kAllMessageColumns,
  ),
  MessageUri(
    label: 'ICC (SIM)',
    uri: 'content://sms/icc',
    columns: kSmsColumns,
    isStandard: true,
  ),
];

const List<MessageUri> kMmsUris = [
  MessageUri(
    label: 'All',
    uri: 'content://mms',
    columns: kMmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Inbox',
    uri: 'content://mms/inbox',
    columns: kMmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Sent',
    uri: 'content://mms/sent',
    columns: kMmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Drafts',
    uri: 'content://mms/drafts',
    columns: kMmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Outbox',
    uri: 'content://mms/outbox',
    columns: kMmsColumns,
    isStandard: true,
  ),
  MessageUri(
    label: 'Part',
    uri: 'content://mms/part',
    columns: kMmsPartColumns,
  ),
  MessageUri(
    label: 'Addr',
    uri: 'content://mms/addr',
    columns: kMmsAddrColumns,
  ),
  MessageUri(
    label: 'Conversations',
    uri: 'content://mms-sms/conversations',
    columns: kAllMessageColumns,
  ),
  MessageUri(
    label: 'ThreadID',
    uri: 'content://mms-sms/threadID',
    columns: kAllMessageColumns,
  ),
  MessageUri(
    label: 'Messages',
    uri: 'content://mms-sms/messages',
    columns: kAllMessageColumns,
  ),
  MessageUri(
    label: 'Search',
    uri: 'content://mms-sms/search',
    columns: kAllMessageColumns,
  ),
  MessageUri(
    label: 'Draft',
    uri: 'content://mms-sms/draft',
    columns: kAllMessageColumns,
  ),
];
