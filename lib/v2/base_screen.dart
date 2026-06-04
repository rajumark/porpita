import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:porpita/services/device_manager.dart';
import 'sidebar/sidebar.dart';
import 'playarea/play_area.dart';
import 'playarea/screens/apps/apps_base_screen.dart';
import 'playarea/screens/calllogs/calllogs_base_screen.dart';
import 'playarea/screens/messages/messages_base_screen.dart';
import 'playarea/screens/contacts/contacts_base_screen.dart';
import 'playarea/screens/settings/settings_screen.dart';
import 'playarea/screens/terminal/terminal_screen.dart';
import 'playarea/screens/debuginfo/debuginfo_screen.dart';
import 'playarea/screens/ui_inspector/ui_inspector_screen.dart';
import 'topbar/topbar.dart';
import 'quickpanel/quick_panel.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  static const _selectedIndexKey = 'sidebar_selected_index';

  int _selectedIndex = 0;
  bool _showSidebar = true;
  bool _showQuickSettings = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_selectedIndexKey) ?? 0;
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedIndexKey, index);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const AppsBaseScreen();
      case 1:
        return const CallLogsBaseScreen();
      case 2:
        return const MessagesBaseScreen();
      case 3:
        return const ContactsBaseScreen();
      case 4:
        return const SettingsScreen();
      case 5:
        return const TerminalScreen();
      case 6:
        return const DebugInfoScreen();
      case 7:
        return const UiInspectorScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final deviceId = dm.selected?.id;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Column(
        children: [
          TopBar(
            onMenuTap: () => setState(() => _showSidebar = !_showSidebar),
            onQuickSettingsTap: () => setState(() => _showQuickSettings = !_showQuickSettings),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: _showSidebar ? 180 : 0,
                  child: _showSidebar
                      ? Sidebar(
                          selectedIndex: _selectedIndex,
                          onItemSelected: (index) {
                            setState(() => _selectedIndex = index);
                            _saveSelectedIndex(index);
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: _showSidebar ? 0 : 8),
                    child: PlayArea(child: _buildScreen(_selectedIndex)),
                  ),
                ),
                if (_showQuickSettings && deviceId != null)
                  QuickPanel(deviceId: deviceId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
