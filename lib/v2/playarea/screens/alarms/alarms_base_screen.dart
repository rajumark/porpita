import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'alarm_model.dart';
import 'alarms_list_screen.dart';
import 'alarm_details_screen.dart';

class AlarmsBaseScreen extends StatefulWidget {
  const AlarmsBaseScreen({super.key});

  @override
  State<AlarmsBaseScreen> createState() => _AlarmsBaseScreenState();
}

class _AlarmsBaseScreenState extends State<AlarmsBaseScreen> {
  AlarmEntry? _selectedEntry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Stack(
          children: [
            AlarmsListScreen(
              onEntrySelected: (entry) => setState(() => _selectedEntry = entry),
            ),
            if (_selectedEntry != null)
              AlarmDetailsScreen(
                entry: _selectedEntry!,
                onBack: () => setState(() => _selectedEntry = null),
              ),
          ],
        ),
      ),
    );
  }
}