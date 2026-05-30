import 'package:flutter/material.dart';
import '../services/commands/calendar_service.dart';
import '../widgets/data_screen_widgets.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'Calendar',
      adbCommand: 'adb shell content query --uri content://com.android.calendar/events',
      fetchData: (id) => CalendarService.fetch(id),
    );
  }
}
