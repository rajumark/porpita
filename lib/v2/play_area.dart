import 'package:flutter/material.dart';

class PlayArea extends StatelessWidget {
  final String? selectedItem;

  const PlayArea({super.key, this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          selectedItem ?? 'Select an item',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
