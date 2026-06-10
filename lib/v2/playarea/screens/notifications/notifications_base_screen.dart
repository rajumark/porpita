import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'notification_model.dart';
import 'notifications_list_screen.dart';
import 'notification_details_screen.dart';

class NotificationsBaseScreen extends StatefulWidget {
  const NotificationsBaseScreen({super.key});

  @override
  State<NotificationsBaseScreen> createState() => _NotificationsBaseScreenState();
}

class _NotificationsBaseScreenState extends State<NotificationsBaseScreen> {
  NotificationEntry? _selectedEntry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Stack(
          children: [
            NotificationsListScreen(
              onEntrySelected: (entry) => setState(() => _selectedEntry = entry),
            ),
            if (_selectedEntry != null)
              NotificationDetailsScreen(
                entry: _selectedEntry!,
                onBack: () => setState(() => _selectedEntry = null),
              ),
          ],
        ),
      ),
    );
  }
}