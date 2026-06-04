import 'package:flutter/material.dart';
import 'debuginfo_widgets.dart';

class DebugTypographyTab extends StatelessWidget {
  const DebugTypographyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final styles = [
      ('Display Large', 'Theme.of(context).textTheme.displayLarge', text.displayLarge),
      ('Display Medium', 'Theme.of(context).textTheme.displayMedium', text.displayMedium),
      ('Display Small', 'Theme.of(context).textTheme.displaySmall', text.displaySmall),
      ('Headline Large', 'Theme.of(context).textTheme.headlineLarge', text.headlineLarge),
      ('Headline Medium', 'Theme.of(context).textTheme.headlineMedium', text.headlineMedium),
      ('Headline Small', 'Theme.of(context).textTheme.headlineSmall', text.headlineSmall),
      ('Title Large', 'Theme.of(context).textTheme.titleLarge', text.titleLarge),
      ('Title Medium', 'Theme.of(context).textTheme.titleMedium', text.titleMedium),
      ('Title Small', 'Theme.of(context).textTheme.titleSmall', text.titleSmall),
      ('Body Large', 'Theme.of(context).textTheme.bodyLarge', text.bodyLarge),
      ('Body Medium', 'Theme.of(context).textTheme.bodyMedium', text.bodyMedium),
      ('Body Small', 'Theme.of(context).textTheme.bodySmall', text.bodySmall),
      ('Label Large', 'Theme.of(context).textTheme.labelLarge', text.labelLarge),
      ('Label Medium', 'Theme.of(context).textTheme.labelMedium', text.labelMedium),
      ('Label Small', 'Theme.of(context).textTheme.labelSmall', text.labelSmall),
    ];

    return ListView.builder(
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final (label, code, style) = styles[index];
        if (style == null) return const SizedBox.shrink();
        return DebugTextTile(
          label: '$label  ${style.fontSize?.toInt()}sp ${style.fontWeight?.value ?? ''}',
          code: code,
          style: style,
        );
      },
    );
  }
}