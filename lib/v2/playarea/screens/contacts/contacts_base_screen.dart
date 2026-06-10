import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'contact_model.dart';
import 'contacts_list_screen.dart';
import 'details/contact_details_screen.dart';

class ContactsBaseScreen extends StatefulWidget {
  const ContactsBaseScreen({super.key});

  @override
  State<ContactsBaseScreen> createState() => _ContactsBaseScreenState();
}

class _ContactsBaseScreenState extends State<ContactsBaseScreen> {
  ContactEntry? _selectedContact;

  void _handleContactSelected(ContactEntry e) {
    setState(() => _selectedContact = e);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Stack(
          children: [
            ContactsListScreen(onContactSelected: _handleContactSelected),
            if (_selectedContact != null)
              _ContactOverlay(
                entry: _selectedContact!,
                onBack: () => setState(() => _selectedContact = null),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactOverlay extends StatelessWidget {
  final ContactEntry entry;
  final VoidCallback onBack;
  const _ContactOverlay({required this.entry, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final device = context.watch<DeviceManager>().selected;
    if (device == null) {
      return RoundedContainer(
        child: Center(
          child: Text(
            'No device connected',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    return ContactDetailsScreen(
      deviceId: device.id,
      contactId: entry.id,
      onBack: onBack,
    );
  }
}
