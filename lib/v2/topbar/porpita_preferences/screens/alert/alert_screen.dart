import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  static const keyUninstall = 'alert_confirm_uninstall';
  static const keyClearData = 'alert_confirm_clear_data';
  static const keyReplaceFolder = 'alert_skip_replace_folder';

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  bool _confirmUninstall = true;
  bool _confirmClearData = true;
  bool _skipReplaceFolder = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _confirmUninstall = prefs.getBool(AlertScreen.keyUninstall) ?? true;
        _confirmClearData = prefs.getBool(AlertScreen.keyClearData) ?? true;
        _skipReplaceFolder = prefs.getBool(AlertScreen.keyReplaceFolder) ?? false;
      });
    }
  }

  Future<void> _toggleUninstall(bool value) async {
    setState(() => _confirmUninstall = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AlertScreen.keyUninstall, value);
  }

  Future<void> _toggleClearData(bool value) async {
    setState(() => _confirmClearData = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AlertScreen.keyClearData, value);
  }

  Future<void> _toggleReplaceFolder(bool value) async {
    setState(() => _skipReplaceFolder = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AlertScreen.keyReplaceFolder, value);
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
        const Divider(),
        SwitchListTile(
          title: const Text('Skip replace folder confirmation'),
          subtitle: const Text('Automatically replace existing download folders without asking'),
          value: _skipReplaceFolder,
          onChanged: _toggleReplaceFolder,
        ),
      ],
    );
  }
}
