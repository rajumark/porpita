import 'package:flutter/material.dart';

class PlayArea extends StatelessWidget {
  final Widget child;

  const PlayArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: child);
  }
}
