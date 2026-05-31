import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugInfoScreen extends StatelessWidget {
  const DebugInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Techdetails'),
              Tab(text: 'Colors'),
              Tab(text: 'Typography'),
              Tab(text: 'Cards'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TechDetailsTab(),
                _ColorsTab(),
                _TypographyTab(),
                _CardsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String text;
  const _CopyButton(this.text);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy, size: 16),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String code;

  const _Tile({required this.label, required this.code});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: _CopyButton(code),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(code, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final String label;
  final String code;
  final Color color;

  const _ColorTile({required this.label, required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CopyButton(code),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(code, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _TextTile extends StatelessWidget {
  final String label;
  final String code;
  final TextStyle style;

  const _TextTile({required this.label, required this.code, required this.style});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: _CopyButton(code),
      title: Text(label, style: style),
      subtitle: Text(code, style: Theme.of(context).textTheme.bodySmall),
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
        return _Tile(label: label, code: code);
      },
    );
  }
}

class _ColorsTab extends StatelessWidget {
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
        return _ColorTile(label: label, code: code, color: color);
      },
    );
  }
}

class _TypographyTab extends StatelessWidget {
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
        return _TextTile(
          label: '$label  ${style.fontSize?.toInt()}sp ${style.fontWeight?.value ?? ''}',
          code: code,
          style: style,
        );
      },
    );
  }
}

class _CardsTab extends StatelessWidget {
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
        _Tile(label: 'Card Color', code: 'Theme.of(context).cardColor'),
        _Tile(label: 'Card Theme Elevation', code: 'Theme.of(context).cardTheme.elevation'),
        _Tile(label: 'Card Theme Shape', code: 'Theme.of(context).cardTheme.shape'),
        _Tile(label: 'Card Theme Margin', code: 'Theme.of(context).cardTheme.margin'),
        _Tile(label: 'Dialog Theme Elevation', code: 'Theme.of(context).dialogTheme.elevation'),
        _Tile(label: 'Dialog Theme Shape', code: 'Theme.of(context).dialogTheme.shape'),
      ],
    );
  }
}
