import 'package:flutter/material.dart';

import 'xml_tree_model.dart';

class XmlTreeWidget extends StatefulWidget {
  final XmlTreeModel treeModel;
  final Set<int> expandedNodes;
  final Set<int> highlightedIndices;
  final ValueChanged<int> onToggleExpand;

  const XmlTreeWidget({
    super.key,
    required this.treeModel,
    required this.expandedNodes,
    this.highlightedIndices = const {},
    required this.onToggleExpand,
  });

  @override
  State<XmlTreeWidget> createState() => _XmlTreeWidgetState();
}

class _XmlTreeWidgetState extends State<XmlTreeWidget> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _nodeKeys = {};

  @override
  void didUpdateWidget(XmlTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedIndices.isNotEmpty &&
        !_setEquals(widget.highlightedIndices, oldWidget.highlightedIndices)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFirstHighlighted());
    }
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  Future<void> _scrollToFirstHighlighted() async {
    if (widget.highlightedIndices.isEmpty) return;
    final firstIndex = widget.highlightedIndices.first;
    final key = _nodeKeys[firstIndex];
    if (key?.currentContext == null) return;

    await Scrollable.ensureVisible(
      key!.currentContext!,
      alignment: 0.3,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleNodes = _computeVisibleNodes();
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      itemCount: visibleNodes.length,
      itemBuilder: (context, index) {
        final node = visibleNodes[index];
        final isHighlighted = widget.highlightedIndices.contains(node.flatIndex);
        final isExpanded = widget.expandedNodes.contains(node.flatIndex);

        _nodeKeys.putIfAbsent(node.flatIndex, () => GlobalKey());

        return _XmlNodeRow(
          key: _nodeKeys[node.flatIndex],
          node: node,
          isHighlighted: isHighlighted,
          isExpanded: isExpanded,
          colorScheme: colorScheme,
          onToggleExpand: () => widget.onToggleExpand(node.flatIndex),
        );
      },
    );
  }

  List<XmlNode> _computeVisibleNodes() {
    final result = <XmlNode>[];
    _collectVisible(widget.treeModel.root, result);
    return result;
  }

  void _collectVisible(XmlNode node, List<XmlNode> result) {
    result.add(node);
    if (node.hasChildren && widget.expandedNodes.contains(node.flatIndex)) {
      for (final child in node.children) {
        _collectVisible(child, result);
      }
    }
  }
}

class _XmlNodeRow extends StatelessWidget {
  final XmlNode node;
  final bool isHighlighted;
  final bool isExpanded;
  final ColorScheme colorScheme;
  final VoidCallback onToggleExpand;

  static const double _indentWidth = 18.0;
  static const double _iconSize = 16.0;

  const _XmlNodeRow({
    super.key,
    required this.node,
    required this.isHighlighted,
    required this.isExpanded,
    required this.colorScheme,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.hasChildren;
    final indent = node.depth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsets.only(left: indent * _indentWidth),
      decoration: BoxDecoration(
        color: isHighlighted ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isHighlighted ? colorScheme.secondary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: hasChildren ? onToggleExpand : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: Row(
            children: [
              _buildExpandIcon(hasChildren),
              const SizedBox(width: 4),
              Expanded(child: _buildLabel()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandIcon(bool hasChildren) {
    if (!hasChildren) {
      return const SizedBox(width: _iconSize, height: _iconSize);
    }

    return GestureDetector(
      onTap: onToggleExpand,
      child: SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: Icon(
          isExpanded ? Icons.expand_more : Icons.chevron_right,
          size: _iconSize,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLabel() {
    final textColor = isHighlighted
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: node.shortTag,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isHighlighted
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.primary,
            ),
          ),
          if (node.text != null && node.text!.isNotEmpty)
            TextSpan(
              text: ' "${node.text}"',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: textColor,
              ),
            ),
          if (node.resourceId != null && node.resourceId!.isNotEmpty)
            TextSpan(
              text: ' ${node.resourceId}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
