import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';

const menuItems = ['Apps', 'Call Logs', 'Messages', 'Contacts', 'Notifications', 'Battery', 'Device Info', 'Lifecycle', 'Alarms', 'Media', 'Files', 'Settings', 'Terminal', 'DebugInfo', 'UI Inspector', 'SystemUI'];
const menuIcons = [
  Icons.widgets_outlined,
  Icons.history_outlined,
  Icons.message_outlined,
  Icons.contacts_outlined,
  Icons.notifications_outlined,
  Icons.battery_std_outlined,
  Icons.device_hub_outlined,
  Icons.autorenew_outlined,
  Icons.alarm_outlined,
  Icons.perm_media_outlined,
  Icons.folder_outlined,
  Icons.settings_outlined,
  Icons.terminal_outlined,
  Icons.bug_report_outlined,
  Icons.phone_android_outlined,
  Icons.dashboard_outlined,
];
const menuIconsSelected = [
  Icons.widgets,
  Icons.history,
  Icons.message,
  Icons.contacts,
  Icons.notifications,
  Icons.battery_std,
  Icons.device_hub,
  Icons.autorenew,
  Icons.alarm,
  Icons.perm_media,
  Icons.folder,
  Icons.settings,
  Icons.terminal,
  Icons.bug_report,
  Icons.phone_android,
  Icons.dashboard,
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
