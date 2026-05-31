import 'package:flutter/material.dart';

import 'sidebar.dart';
import 'play_area.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  iconSize: 24,
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
                const Text('Porpita'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Sidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
                PlayArea(
                  selectedItem: _selectedIndex >= 0
                      ? 'Item ${_selectedIndex + 1}'
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
