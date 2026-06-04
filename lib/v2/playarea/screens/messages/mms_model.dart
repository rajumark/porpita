import 'package:flutter/material.dart';

class MmsEntry {
  final String id;
  final String threadId;
  final DateTime date;
  final DateTime dateSent;
  final String msgBox;
  final String read;
  final String mId;
  final String sub;
  final String subCs;
  final String ctT;
  final String ctL;
  final String exp;
  final String mCls;
  final String mType;
  final String v;
  final String mSize;
  final String pri;
  final String rr;
  final String rptA;
  final String respSt;
  final String st;
  final String trId;
  final String retrSt;
  final String retrTxt;
  final String retrTxtCs;
  final String readStatus;
  final String ctCls;
  final String respTxt;
  final String dTm;
  final String dRpt;
  final String locked;
  final String subId;
  final String mTypeVnd;
  final String creator;
  final String seen;
  final String textOnly;
  final Map<String, String> raw;

  const MmsEntry({
    required this.id,
    required this.threadId,
    required this.date,
    required this.dateSent,
    required this.msgBox,
    required this.read,
    required this.mId,
    required this.sub,
    required this.subCs,
    required this.ctT,
    required this.ctL,
    required this.exp,
    required this.mCls,
    required this.mType,
    required this.v,
    required this.mSize,
    required this.pri,
    required this.rr,
    required this.rptA,
    required this.respSt,
    required this.st,
    required this.trId,
    required this.retrSt,
    required this.retrTxt,
    required this.retrTxtCs,
    required this.readStatus,
    required this.ctCls,
    required this.respTxt,
    required this.dTm,
    required this.dRpt,
    required this.locked,
    required this.subId,
    required this.mTypeVnd,
    required this.creator,
    required this.seen,
    required this.textOnly,
    required this.raw,
  });

  String get msgBoxLabel {
    switch (msgBox) {
      case '1':
        return 'Inbox';
      case '2':
        return 'Sent';
      case '3':
        return 'Draft';
      case '4':
        return 'Outbox';
      default:
        return msgBox.isEmpty ? '—' : msgBox;
    }
  }

  bool get isIncoming => msgBox == '1';
  bool get isOutgoing => msgBox == '2';
  bool get isUnread => read == '0';

  String get displayAddress {
    if (mId.isNotEmpty) return mId;
    if (sub.isNotEmpty) return sub;
    return 'MMS #$id';
  }

  String get contentType {
    if (ctT.isNotEmpty) return ctT;
    return '—';
  }

  String get preview {
    if (sub.isNotEmpty && !sub.startsWith('proto:')) return sub;
    return contentType;
  }

  String get sizeDisplay {
    if (mSize.isEmpty) return '—';
    final bytes = int.tryParse(mSize) ?? 0;
    if (bytes <= 0) return mSize;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
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

  factory MmsEntry.fromMap(Map<String, String> map) {
    final dateMs = int.tryParse(map['date'] ?? '') ?? 0;
    final dateSentMs = int.tryParse(map['date_sent'] ?? '') ?? 0;

    return MmsEntry(
      id: map['_id'] ?? '',
      threadId: map['thread_id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      dateSent: DateTime.fromMillisecondsSinceEpoch(dateSentMs),
      msgBox: map['msg_box'] ?? '',
      read: map['read'] ?? '',
      mId: map['m_id'] ?? '',
      sub: map['sub'] ?? '',
      subCs: map['sub_cs'] ?? '',
      ctT: map['ct_t'] ?? '',
      ctL: map['ct_l'] ?? '',
      exp: map['exp'] ?? '',
      mCls: map['m_cls'] ?? '',
      mType: map['m_type'] ?? '',
      v: map['v'] ?? '',
      mSize: map['m_size'] ?? '',
      pri: map['pri'] ?? '',
      rr: map['rr'] ?? '',
      rptA: map['rpt_a'] ?? '',
      respSt: map['resp_st'] ?? '',
      st: map['st'] ?? '',
      trId: map['tr_id'] ?? '',
      retrSt: map['retr_st'] ?? '',
      retrTxt: map['retr_txt'] ?? '',
      retrTxtCs: map['retr_txt_cs'] ?? '',
      readStatus: map['read_status'] ?? '',
      ctCls: map['ct_cls'] ?? '',
      respTxt: map['resp_txt'] ?? '',
      dTm: map['d_tm'] ?? '',
      dRpt: map['d_rpt'] ?? '',
      locked: map['locked'] ?? '',
      subId: map['sub_id'] ?? '',
      mTypeVnd: map['m_type_vnd'] ?? '',
      creator: map['creator'] ?? '',
      seen: map['seen'] ?? '',
      textOnly: map['text_only'] ?? '',
      raw: Map<String, String>.from(map),
    );
  }
}

const List<String> kMmsColumns = [
  '_id',
  'thread_id',
  'date',
  'date_sent',
  'msg_box',
  'read',
  'm_id',
  'sub',
  'sub_cs',
  'ct_t',
  'ct_l',
  'exp',
  'm_cls',
  'm_type',
  'v',
  'm_size',
  'pri',
  'rr',
  'rpt_a',
  'resp_st',
  'st',
  'tr_id',
  'retr_st',
  'retr_txt',
  'retr_txt_cs',
  'read_status',
  'ct_cls',
  'resp_txt',
  'd_tm',
  'd_rpt',
  'locked',
  'sub_id',
  'm_type_vnd',
  'creator',
  'seen',
  'text_only',
];

const List<String> kMmsPartColumns = [
  '_id',
  'mid',
  'seq',
  'ct',
  'name',
  'chset',
  'cd',
  'fn',
  'cid',
  'cl',
  'ctt_s',
  'ctt_t',
  '_data',
  'text',
  'sub_id',
];

const List<String> kMmsAddrColumns = [
  '_id',
  'msg_id',
  'contact_id',
  'address',
  'type',
  'charset',
  'sub_id',
];
