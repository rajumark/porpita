import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';

const menuItems = ['Apps', 'Call Logs', 'Messages', 'Contacts', 'Settings', 'Terminal', 'DebugInfo', 'UI Inspector'];
const menuIcons = [
  Icons.widgets_outlined,
  Icons.history_outlined,
  Icons.message_outlined,
  Icons.contacts_outlined,
  Icons.settings_outlined,
  Icons.terminal_outlined,
  Icons.bug_report_outlined,
  Icons.phone_android_outlined,
];
const menuIconsSelected = [
  Icons.widgets,
  Icons.history,
  Icons.message,
  Icons.contacts,
  Icons.settings,
  Icons.terminal,
  Icons.bug_report,
  Icons.phone_android,
];

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppSidebar(
      items: menuItems,
      icons: menuIcons,
      selectedIcons: menuIconsSelected,
      selectedIndex: selectedIndex,
      onItemSelected: onItemSelected,
    );
  }
}
