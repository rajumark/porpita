import 'package:flutter/material.dart';

import 'sidebar/sidebar.dart';
import 'playarea/play_area.dart';
import 'playarea/screens/apps/apps_base_screen.dart';
import 'playarea/screens/settings/settings_screen.dart';
import 'playarea/screens/terminal/terminal_screen.dart';
import 'playarea/screens/debuginfo/debuginfo_screen.dart';
import 'topbar/topbar.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const AppsBaseScreen();
      case 1:
        return const SettingsScreen();
      case 2:
        return const TerminalScreen();
      case 3:
        return const DebugInfoScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Row(
              children: [
                Sidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
                PlayArea(child: _buildScreen(_selectedIndex)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
