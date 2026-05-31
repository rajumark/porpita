import 'package:flutter/material.dart';
import 'package:porpita/v2/widgets/app_sidebar.dart';
import 'screens/theme/theme_screen.dart';
import 'screens/alert/alert_screen.dart';
import 'screens/about/about_screen.dart';

const _menuItems = ['Theme', 'Alert', 'About'];

class PorpitaPreferencesDialog extends StatefulWidget {
  const PorpitaPreferencesDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const PorpitaPreferencesDialog(),
    );
  }

  @override
  State<PorpitaPreferencesDialog> createState() => _PorpitaPreferencesDialogState();
}

class _PorpitaPreferencesDialogState extends State<PorpitaPreferencesDialog> {
  int _selectedIndex = 0;

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const ThemeScreen();
      case 1:
        return const AlertScreen();
      case 2:
        return const AboutScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
        vertical: size.height * 0.1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
                const Text('Preferences'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                AppSidebar(
                  items: _menuItems,
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
                Expanded(child: _buildScreen(_selectedIndex)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
