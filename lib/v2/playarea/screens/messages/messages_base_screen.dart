import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'sms_model.dart';
import 'mms_model.dart';
import 'raw_message_entry.dart';
import 'messages_list_screen.dart';
import 'sms_details_screen.dart';
import 'mms_details_screen.dart';
import 'raw_message_details_screen.dart';
import '../contacts/details/contact_details_screen.dart';
import '../contacts/contacts_service.dart';

class MessagesBaseScreen extends StatefulWidget {
  const MessagesBaseScreen({super.key});

  @override
  State<MessagesBaseScreen> createState() => _MessagesBaseScreenState();
}

class _MessagesBaseScreenState extends State<MessagesBaseScreen> {
  SmsEntry? _selectedSms;
  MmsEntry? _selectedMms;
  RawMessageEntry? _selectedRaw;
  _ContactLookupState? _contactLookup;

  void _handleSmsSelected(SmsEntry e) {
    setState(() {
      _selectedSms = e;
      _selectedMms = null;
      _selectedRaw = null;
    });
  }

  void _handleMmsSelected(MmsEntry e) {
    setState(() {
      _selectedMms = e;
      _selectedSms = null;
      _selectedRaw = null;
    });
  }

  void _handleRawSelected(RawMessageEntry e) {
    setState(() {
      _selectedRaw = e;
      _selectedSms = null;
      _selectedMms = null;
    });
  }

  void _handleViewContact(String number) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }
    if (number.isEmpty) return;

    setState(() => _contactLookup = _ContactLookupState.loading(number));
    final details = await ContactsService.fetchContactDetailsByNumber(
      device.id,
      number,
    );
    if (!mounted) return;
    if (details.summary == null && details.dataRows.isEmpty) {
      setState(() => _contactLookup = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No contact found for $number')),
      );
      return;
    }
    setState(() {
      _contactLookup = _ContactLookupState.loaded(number, details.summary!.id);
    });
  }

  void _closeContactLookup() {
    setState(() => _contactLookup = null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Stack(
          children: [
            MessagesListScreen(
              onSmsSelected: _handleSmsSelected,
              onMmsSelected: _handleMmsSelected,
              onRawSelected: _handleRawSelected,
              onSmsViewContact: (e) => _handleViewContact(e.address),
              onMmsViewContact: (e) => _handleViewContact(e.mId),
            ),
            if (_selectedSms != null)
              SmsDetailsScreen(
                entry: _selectedSms!,
                onBack: () => setState(() => _selectedSms = null),
              ),
            if (_selectedMms != null)
              MmsDetailsScreen(
                entry: _selectedMms!,
                onBack: () => setState(() => _selectedMms = null),
              ),
            if (_selectedRaw != null)
              RawMessageDetailsScreen(
                entry: _selectedRaw!,
                onBack: () => setState(() => _selectedRaw = null),
              ),
            if (_contactLookup != null)
              _ContactLookupOverlay(
                state: _contactLookup!,
                onBack: _closeContactLookup,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactLookupState {
  final String number;
  final String? contactId;
  final bool loading;
  const _ContactLookupState.loading(this.number)
      : contactId = null,
        loading = true;
  const _ContactLookupState.loaded(this.number, this.contactId)
      : loading = false;
}

class _ContactLookupOverlay extends StatelessWidget {
  final _ContactLookupState state;
  final VoidCallback onBack;
  const _ContactLookupOverlay({required this.state, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final device = context.watch<DeviceManager>().selected;
    if (device == null) return const SizedBox.shrink();
    if (state.loading || state.contactId == null) {
      return RoundedContainer(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'Looking up ${state.number}…',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }
    return ContactDetailsScreen(
      deviceId: device.id,
      contactId: state.contactId!,
      onBack: onBack,
    );
  }
}
