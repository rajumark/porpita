import 'package:flutter/material.dart';
import 'appslist/appslist_screen.dart';

class AppsBaseScreen extends StatelessWidget {
  const AppsBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: const AppsListScreen(),
      ),
    );
  }
}
