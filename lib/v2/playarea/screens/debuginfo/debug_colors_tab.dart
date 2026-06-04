import 'package:flutter/material.dart';
import 'debuginfo_widgets.dart';

class DebugColorsTab extends StatelessWidget {
  const DebugColorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final colors = [
      ('Primary', 'Theme.of(context).colorScheme.primary', scheme.primary),
      ('On Primary', 'Theme.of(context).colorScheme.onPrimary', scheme.onPrimary),
      ('Primary Container', 'Theme.of(context).colorScheme.primaryContainer', scheme.primaryContainer),
      ('On Primary Container', 'Theme.of(context).colorScheme.onPrimaryContainer', scheme.onPrimaryContainer),
      ('Secondary', 'Theme.of(context).colorScheme.secondary', scheme.secondary),
      ('On Secondary', 'Theme.of(context).colorScheme.onSecondary', scheme.onSecondary),
      ('Secondary Container', 'Theme.of(context).colorScheme.secondaryContainer', scheme.secondaryContainer),
      ('On Secondary Container', 'Theme.of(context).colorScheme.onSecondaryContainer', scheme.onSecondaryContainer),
      ('Tertiary', 'Theme.of(context).colorScheme.tertiary', scheme.tertiary),
      ('On Tertiary', 'Theme.of(context).colorScheme.onTertiary', scheme.onTertiary),
      ('Tertiary Container', 'Theme.of(context).colorScheme.tertiaryContainer', scheme.tertiaryContainer),
      ('On Tertiary Container', 'Theme.of(context).colorScheme.onTertiaryContainer', scheme.onTertiaryContainer),
      ('Error', 'Theme.of(context).colorScheme.error', scheme.error),
      ('On Error', 'Theme.of(context).colorScheme.onError', scheme.onError),
      ('Error Container', 'Theme.of(context).colorScheme.errorContainer', scheme.errorContainer),
      ('On Error Container', 'Theme.of(context).colorScheme.onErrorContainer', scheme.onErrorContainer),
      ('Surface', 'Theme.of(context).colorScheme.surface', scheme.surface),
      ('On Surface', 'Theme.of(context).colorScheme.onSurface', scheme.onSurface),
      ('Surface Container Lowest', 'Theme.of(context).colorScheme.surfaceContainerLowest', scheme.surfaceContainerLowest),
      ('Surface Container Low', 'Theme.of(context).colorScheme.surfaceContainerLow', scheme.surfaceContainerLow),
      ('Surface Container', 'Theme.of(context).colorScheme.surfaceContainer', scheme.surfaceContainer),
      ('Surface Container High', 'Theme.of(context).colorScheme.surfaceContainerHigh', scheme.surfaceContainerHigh),
      ('Surface Container Highest', 'Theme.of(context).colorScheme.surfaceContainerHighest', scheme.surfaceContainerHighest),
      ('On Surface Variant', 'Theme.of(context).colorScheme.onSurfaceVariant', scheme.onSurfaceVariant),
      ('Outline', 'Theme.of(context).colorScheme.outline', scheme.outline),
      ('Outline Variant', 'Theme.of(context).colorScheme.outlineVariant', scheme.outlineVariant),
      ('Shadow', 'Theme.of(context).colorScheme.shadow', scheme.shadow),
      ('Scrim', 'Theme.of(context).colorScheme.scrim', scheme.scrim),
      ('Inverse Surface', 'Theme.of(context).colorScheme.inverseSurface', scheme.inverseSurface),
      ('On Inverse Surface', 'Theme.of(context).colorScheme.onInverseSurface', scheme.onInverseSurface),
      ('Inverse Primary', 'Theme.of(context).colorScheme.inversePrimary', scheme.inversePrimary),
    ];

    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final (label, code, color) = colors[index];
        return DebugColorTile(label: label, code: code, color: color);
      },
    );
  }
}