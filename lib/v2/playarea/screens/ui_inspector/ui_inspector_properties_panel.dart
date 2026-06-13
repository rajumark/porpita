import 'package:flutter/material.dart';

import 'xml_tree_model.dart';

class UiInspectorPropertiesPanel extends StatelessWidget {
  final XmlNode? node;
  final VoidCallback onClose;

  const UiInspectorPropertiesPanel({
    super.key,
    required this.node,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.list_alt, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Properties',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (node == null)
          const Expanded(
            child: Center(child: Text('No element selected')),
          )
        else
          Expanded(
            child: _PropertyList(node: node!),
          ),
      ],
    );
  }
}

class _PropertyList extends StatelessWidget {
  final XmlNode node;

  const _PropertyList({required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = node.attributes.entries.toList();

    return ListViewItemBuilder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _PropertyRow(
          propKey: entry.key,
          propValue: entry.value,
          isEven: index.isEven,
          theme: theme,
        );
      },
    );
  }
}

class ListViewItemBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const ListViewItemBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String propKey;
  final String propValue;
  final bool isEven;
  final ThemeData theme;

  const _PropertyRow({
    required this.propKey,
    required this.propValue,
    required this.isEven,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              propKey,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              propValue.isEmpty ? '—' : propValue,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: propValue.isEmpty ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}