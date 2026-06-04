import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'call_log_model.dart';
import 'calllogs_list_screen.dart';
import 'calllog_details_screen.dart';
import '../contacts/details/contact_details_screen.dart';
import '../contacts/contacts_service.dart';

class CallLogsBaseScreen extends StatefulWidget {
  const CallLogsBaseScreen({super.key});

  @override
  State<CallLogsBaseScreen> createState() => _CallLogsBaseScreenState();
}

class _CallLogsBaseScreenState extends State<CallLogsBaseScreen> {
  CallLogEntry? _selectedEntry;
  _ContactLookupState? _contactLookup;

  void _handleViewContact(CallLogEntry entry) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }
    final number = entry.displayNumber;
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
            CallLogsListScreen(
              onEntrySelected: (entry) => setState(() => _selectedEntry = entry),
              onViewContact: _handleViewContact,
            ),
            if (_selectedEntry != null)
              CallLogDetailsScreen(
                entry: _selectedEntry!,
                onBack: () => setState(() => _selectedEntry = null),
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
