import 'package:flutter/material.dart';
import 'appslist/appslist_screen.dart';

class AppsBaseScreen extends StatelessWidget {
  const AppsBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: const AppsListScreen(),
      ),
    );
  }
}
