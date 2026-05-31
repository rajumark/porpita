import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';

const menuItems = ['Apps', 'Settings', 'Terminal', 'DebugInfo'];
const menuIcons = [Icons.widgets, Icons.settings, Icons.terminal, Icons.bug_report];

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
      selectedIndex: selectedIndex,
      onItemSelected: onItemSelected,
    );
  }
}
