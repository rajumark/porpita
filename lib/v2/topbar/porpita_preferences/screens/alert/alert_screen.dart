import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  bool _confirmUninstall = true;
  bool _confirmClearData = true;

  static const _keyUninstall = 'alert_confirm_uninstall';
  static const _keyClearData = 'alert_confirm_clear_data';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _confirmUninstall = prefs.getBool(_keyUninstall) ?? true;
        _confirmClearData = prefs.getBool(_keyClearData) ?? true;
      });
    }
  }

  Future<void> _toggleUninstall(bool value) async {
    setState(() => _confirmUninstall = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUninstall, value);
  }

  Future<void> _toggleClearData(bool value) async {
    setState(() => _confirmClearData = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyClearData, value);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Confirm before uninstall'),
          subtitle: const Text('Show confirmation dialog before uninstalling an app'),
          value: _confirmUninstall,
          onChanged: _toggleUninstall,
        ),
        SwitchListTile(
          title: const Text('Confirm before clear data'),
          subtitle: const Text('Show confirmation dialog before clearing app data'),
          value: _confirmClearData,
          onChanged: _toggleClearData,
        ),
      ],
    );
  }
}
