import 'package:flutter/material.dart';
import 'debuginfo_widgets.dart';

class DebugCardsTab extends StatelessWidget {
  const DebugCardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Default Card', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Card Title', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('This is a default Material 3 card with no custom styling.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Elevated Card', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elevated Card', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Card with elevation: 2', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Outlined Card', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Outlined Card', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Card with outline border', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Filled Card', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filled Card', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Card with surfaceContainerHighest fill', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Card Properties', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DebugTile(label: 'Card Color', code: 'Theme.of(context).cardColor'),
        DebugTile(label: 'Card Theme Elevation', code: 'Theme.of(context).cardTheme.elevation'),
        DebugTile(label: 'Card Theme Shape', code: 'Theme.of(context).cardTheme.shape'),
        DebugTile(label: 'Card Theme Margin', code: 'Theme.of(context).cardTheme.margin'),
        DebugTile(label: 'Dialog Theme Elevation', code: 'Theme.of(context).dialogTheme.elevation'),
        DebugTile(label: 'Dialog Theme Shape', code: 'Theme.of(context).dialogTheme.shape'),
      ],
    );
  }
}