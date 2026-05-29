import 'package:flutter/material.dart';

import '../widgets/settings_dialog.dart';
import 'apps_page.dart';
import 'debug_page.dart';
import 'settings_page.dart';

enum PageItem {
  debug('Debug', Icons.bug_report, DebugPage()),
  apps('Apps', Icons.apps, AppsPage()),
  settings('Settings', Icons.settings, SettingsPage());

  final String label;
  final IconData icon;
  final Widget page;
  const PageItem(this.label, this.icon, this.page);
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final _pages = PageItem.values;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedIndex].label),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const SettingsDialog(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Text(
                'Porpita',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ..._pages.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                selected: i == _selectedIndex,
                onTap: () {
                  setState(() => _selectedIndex = i);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
      body: _pages[_selectedIndex].page,
    );
  }
}
