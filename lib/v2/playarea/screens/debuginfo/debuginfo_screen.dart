import 'package:flutter/material.dart';
import 'debug_adb_tab.dart';
import 'debuginfo_widgets.dart';
import 'debug_colors_tab.dart';
import 'debug_typography_tab.dart';
import 'debug_cards_tab.dart';
import 'debug_experimental_tab.dart';

class DebugInfoScreen extends StatelessWidget {
  const DebugInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'ADB'),
              Tab(text: 'Techdetails'),
              Tab(text: 'Colors'),
              Tab(text: 'Typography'),
              Tab(text: 'Cards'),
              Tab(text: 'Experimental'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                DebugAdbTab(),
                _TechDetailsTab(),
                DebugColorsTab(),
                DebugTypographyTab(),
                DebugCardsTab(),
                DebugExperimentalTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechDetailsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final items = [
      ('Brightness', 'Theme.of(context).brightness', '${scheme.brightness}'),
      ('Seed Color', 'ColorScheme.fromSeed(seedColor: Colors.deepPurple)', 'Colors.deepPurple'),
      ('Material 3', 'ThemeData(useMaterial3: true)', '${theme.useMaterial3}'),
      ('Platform', 'Theme.of(context).platform', '${mediaQuery.platformBrightness}'),
      ('Device Pixel Ratio', 'MediaQuery.of(context).devicePixelRatio', '${mediaQuery.devicePixelRatio}'),
      ('Text Scale', 'MediaQuery.of(context).textScaler', '${mediaQuery.textScaler}'),
      ('Padding', 'MediaQuery.of(context).viewPadding', '${mediaQuery.viewPadding}'),
      ('Size', 'MediaQuery.of(context).size', '${mediaQuery.size}'),
    ];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final (label, code, value) = items[index];
        return DebugTile(label: label, code: code);
      },
    );
  }
}