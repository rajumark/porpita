import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import '../contact_model.dart';
import '../contacts_service.dart';

class ContactDetailsScreen extends StatefulWidget {
  final String deviceId;
  final String contactId;
  final VoidCallback? onBack;
  final String? lookupPhoneNumber;

  const ContactDetailsScreen({
    super.key,
    required this.deviceId,
    required this.contactId,
    this.onBack,
    this.lookupPhoneNumber,
  });

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  ContactDetails? _details;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ContactDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contactId != widget.contactId ||
        oldWidget.deviceId != widget.deviceId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _details = null;
    });
    final details = await ContactsService.fetchContactDetails(
      widget.deviceId,
      widget.contactId,
    );
    if (!mounted) return;
    setState(() {
      _details = details;
      _loading = false;
    });
  }

  Future<void> _call(String number) async {
    final sanitized = number.replaceAll(RegExp(r'[^\d+*#,]'), '');
    await AdbExecService.run(widget.deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.CALL',
      '-d', 'tel:$sanitized',
    ]);
  }

  Future<void> _sms(String number) async {
    final sanitized = number.replaceAll(RegExp(r'[^\d+*#,]'), '');
    await AdbExecService.run(widget.deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.SENDTO',
      '-d', 'smsto:$sanitized',
    ]);
  }

  Future<void> _email(String address) async {
    await AdbExecService.run(widget.deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.SENDTO',
      '-d', 'mailto:$address',
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final details = _details;
    if (details == null) {
      return Center(child: Text('No contact data', style: Theme.of(context).textTheme.bodyMedium));
    }

    if (details.error != null && details.isEmpty) {
      return Center(
        child: Text(details.error!, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final nameEntry = details.primaryName;
    final name = nameEntry?.primaryValue ?? details.summary?.name ?? 'Contact';
    final summary = details.summary;

    return Column(
      children: [
        _buildHeader(context, name, summary),
        Expanded(child: _buildSections(context, details)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String name, ContactEntry? summary) {
    final scheme = Theme.of(context).colorScheme;
    final initials = _initials(name);

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          if (widget.onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 24,
              onPressed: widget.onBack,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(const Size(36, 36)),
            ),
          CircleAvatar(
            radius: 16,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              initials,
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (summary != null)
                  Text(
                    'ID #${summary.id}  ·  ${summary.lookup.isEmpty ? 'no lookup' : summary.lookup}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 18,
            tooltip: 'Refresh',
            onPressed: _load,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final n = name.trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
    }
    return n.characters.first.toUpperCase();
  }

  Widget _buildSections(BuildContext context, ContactDetails details) {
    final sections = <_SectionData>[];

    if (details.phones.isNotEmpty) {
      sections.add(_SectionData(
        title: 'Phones (${details.phones.length})',
        icon: Icons.phone_outlined,
        rows: details.phones
            .map((p) => _RowData(
                  label: p.dataFields['data2'] ?? '',
                  value: p.primaryValue,
                  actions: [
                    _ActionData(
                      icon: Icons.call,
                      tooltip: 'Call',
                      onTap: () => _call(p.primaryValue),
                    ),
                    _ActionData(
                      icon: Icons.message_outlined,
                      tooltip: 'Message',
                      onTap: () => _sms(p.primaryValue),
                    ),
                    _ActionData(
                      icon: Icons.content_copy,
                      tooltip: 'Copy',
                      onTap: () => _copy(context, p.primaryValue),
                    ),
                  ],
                ))
            .toList(),
      ));
    }

    if (details.emails.isNotEmpty) {
      sections.add(_SectionData(
        title: 'Emails (${details.emails.length})',
        icon: Icons.email_outlined,
        rows: details.emails
            .map((e) => _RowData(
                  label: e.dataFields['data2'] ?? '',
                  value: e.primaryValue,
                  actions: [
                    _ActionData(
                      icon: Icons.mail_outline,
                      tooltip: 'Send email',
                      onTap: () => _email(e.primaryValue),
                    ),
                    _ActionData(
                      icon: Icons.content_copy,
                      tooltip: 'Copy',
                      onTap: () => _copy(context, e.primaryValue),
                    ),
                  ],
                ))
            .toList(),
      ));
    }

    if (details.addresses.isNotEmpty) {
      sections.add(_SectionData(
        title: 'Addresses (${details.addresses.length})',
        icon: Icons.location_on_outlined,
        rows: details.addresses
            .map((a) => _RowData(
                  label: a.dataFields['data2'] ?? '',
                  value: a.secondaryValue.isNotEmpty
                      ? a.secondaryValue
                      : a.primaryValue,
                ))
            .toList(),
      ));
    }

    if (details.organizations.isNotEmpty) {
      sections.add(_SectionData(
        title: 'Organization',
        icon: Icons.business_outlined,
        rows: details.organizations
            .map((o) => _RowData(
                  label: o.dataFields['data4'] ?? '',
                  value:
                      '${o.dataFields['data1'] ?? ''}${o.dataFields['data4'] != null && o.dataFields['data4']!.isNotEmpty ? ' · ${o.dataFields['data4']}' : ''}',
                ))
            .toList(),
      ));
    }

    if (details.events.isNotEmpty) {
      sections.add(_SectionData(
        title: 'Events (${details.events.length})',
        icon: Icons.event_outlined,
        rows: details.events
            .map((ev) => _RowData(
                  label: ev.dataFields['data2'] ?? '',
                  value: ev.primaryValue,
                ))
            .toList(),
      ));
    }

    if (details.websites.isNotEmpty) {
      sections.add(_SectionData(
        title: 'Websites',
        icon: Icons.link,
        rows: details.websites
            .map((w) => _RowData(label: '', value: w.primaryValue))
            .toList(),
      ));
    }

    if (details.ims.isNotEmpty) {
      sections.add(_SectionData(
        title: 'IM',
        icon: Icons.chat_outlined,
        rows: details.ims
            .map((im) => _RowData(
                  label: im.dataFields['data2'] ?? '',
                  value: im.primaryValue,
                ))
            .toList(),
      ));
    }

    if (details.sips.isNotEmpty) {
      sections.add(_SectionData(
        title: 'SIP',
        icon: Icons.call_made,
        rows: details.sips
            .map((s) => _RowData(label: '', value: s.primaryValue))
            .toList(),
      ));
    }

    if (details.nicknames.isNotEmpty) {
      sections.add(_SectionData(
        title: 'Nicknames',
        icon: Icons.tag,
        rows: details.nicknames
            .map((n) => _RowData(label: '', value: n.primaryValue))
            .toList(),
      ));
    }

    if (details.notes.isNotEmpty) {
      sections.add(_SectionData(
        title: 'Notes',
        icon: Icons.sticky_note_2_outlined,
        rows: details.notes
            .map((n) => _RowData(label: '', value: n.primaryValue))
            .toList(),
      ));
    }

    if (sections.isEmpty) {
      return Center(
        child: Text(
          'No data for this contact',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        for (final section in sections) _buildSection(context, section),
      ],
    );
  }

  Widget _buildSection(BuildContext context, _SectionData section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 4),
            child: Row(
              children: [
                Icon(section.icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  for (int i = 0; i < section.rows.length; i++) ...[
                    _buildRow(context, section.rows[i]),
                    if (i < section.rows.length - 1)
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, _RowData row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (row.label.isNotEmpty)
                  Text(
                    row.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                SelectableText(
                  row.value.isEmpty ? '—' : row.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          for (final action in row.actions)
            IconButton(
              icon: Icon(action.icon, size: 18),
              tooltip: action.tooltip,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(const Size(28, 28)),
              visualDensity: VisualDensity.compact,
              onPressed: action.onTap,
            ),
          if (row.actions.isEmpty)
            IconButton(
              icon: const Icon(Icons.copy, size: 14),
              tooltip: 'Copy',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(const Size(24, 24)),
              visualDensity: VisualDensity.compact,
              onPressed: row.value.isEmpty ? null : () => _copy(context, row.value),
            ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _SectionData {
  final String title;
  final IconData icon;
  final List<_RowData> rows;
  const _SectionData({required this.title, required this.icon, required this.rows});
}

class _RowData {
  final String label;
  final String value;
  final List<_ActionData> actions;
  const _RowData({required this.label, required this.value, this.actions = const []});
}

class _ActionData {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionData({required this.icon, required this.tooltip, required this.onTap});
}
