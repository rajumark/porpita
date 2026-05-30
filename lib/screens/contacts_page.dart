import 'package:flutter/material.dart';
import '../services/commands/contacts_service.dart';
import '../widgets/data_screen_widgets.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'Contacts',
      adbCommand: 'adb shell content query --uri content://com.android.contacts/data',
      fetchData: (id) => ContactsService.fetch(id),
    );
  }
}
