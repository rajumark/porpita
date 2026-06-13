import 'package:flutter/material.dart';

import 'xml_tree_model.dart';

class XmlTreeWidget extends StatefulWidget {
  final XmlTreeModel treeModel;
  final Set<int> expandedNodes;
  final Set<int> highlightedIndices;
  final ValueChanged<int> onToggleExpand;
  final ValueChanged<int>? onNodeSelected;
  final int? focusedFlatIndex;

  const XmlTreeWidget({
    super.key,
    required this.treeModel,
    required this.expandedNodes,
    this.highlightedIndices = const {},
    required this.onToggleExpand,
    this.onNodeSelected,
    this.focusedFlatIndex,
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 2000,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          itemCount: visibleNodes.length,
          itemBuilder: (context, index) {
            final node = visibleNodes[index];
            final isHighlighted = widget.highlightedIndices.contains(node.flatIndex);
            final isExpanded = widget.expandedNodes.contains(node.flatIndex);
            final isBlinking = widget.focusedFlatIndex != null && node.flatIndex == widget.focusedFlatIndex;

            _nodeKeys.putIfAbsent(node.flatIndex, () => GlobalKey());

            return _XmlNodeRow(
              key: _nodeKeys[node.flatIndex],
              node: node,
              isHighlighted: isHighlighted,
              isExpanded: isExpanded,
              isBlinking: isBlinking,
              colorScheme: colorScheme,
              onToggleExpand: () => widget.onToggleExpand(node.flatIndex),
              onTap: () => widget.onNodeSelected?.call(node.flatIndex),
            );
          },
        ),
      ),
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

class _XmlNodeRow extends StatefulWidget {
  final XmlNode node;
  final bool isHighlighted;
  final bool isExpanded;
  final bool isBlinking;
  final ColorScheme colorScheme;
  final VoidCallback onToggleExpand;
  final VoidCallback? onTap;

  static const double _indentWidth = 18.0;
  static const double _iconSize = 16.0;

  const _XmlNodeRow({
    super.key,
    required this.node,
    required this.isHighlighted,
    required this.isExpanded,
    required this.isBlinking,
    required this.colorScheme,
    required this.onToggleExpand,
    this.onTap,
  });

  @override
  State<_XmlNodeRow> createState() => _XmlNodeRowState();
}

class _XmlNodeRowState extends State<_XmlNodeRow> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    if (widget.isBlinking) {
      _startBlink();
    }
  }

  @override
  void didUpdateWidget(_XmlNodeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking && !oldWidget.isBlinking) {
      _startBlink();
    } else if (!widget.isBlinking && oldWidget.isBlinking) {
      _blinkController.stop();
    }
  }

  void _startBlink() {
    _blinkController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _blinkController.stop();
        _blinkController.value = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.hasChildren;
    final indent = widget.node.depth;

    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        final blinkAlpha = widget.isBlinking && _blinkController.isAnimating
            ? _blinkAnimation.value
            : 1.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(left: indent * _XmlNodeRow._indentWidth),
          decoration: BoxDecoration(
            color: widget.isHighlighted
                ? widget.colorScheme.secondaryContainer
                : (widget.isBlinking
                    ? Colors.orange.withValues(alpha: 0.3 * blinkAlpha)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isHighlighted
                  ? widget.colorScheme.secondary
                  : (widget.isBlinking
                      ? Colors.orange.withValues(alpha: blinkAlpha)
                      : Colors.transparent),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
              child: Row(
                children: [
                  _buildExpandIcon(hasChildren),
                  const SizedBox(width: 4),
                  Flexible(child: _buildLabel()),
                  if (widget.node.isFocused) _buildFocusedDot(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandIcon(bool hasChildren) {
    if (!hasChildren) {
      return const SizedBox(width: _XmlNodeRow._iconSize, height: _XmlNodeRow._iconSize);
    }

    return GestureDetector(
      onTap: widget.onToggleExpand,
      child: SizedBox(
        width: _XmlNodeRow._iconSize,
        height: _XmlNodeRow._iconSize,
        child: Icon(
          widget.isExpanded ? Icons.expand_more : Icons.chevron_right,
          size: _XmlNodeRow._iconSize,
          color: widget.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildFocusedDot() {
    return Tooltip(
      message: 'Focused element',
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLabel() {
    final textColor = widget.isHighlighted
        ? widget.colorScheme.onSecondaryContainer
        : widget.colorScheme.onSurface;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: widget.node.shortTag,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.isHighlighted
                  ? widget.colorScheme.onSecondaryContainer
                  : widget.colorScheme.primary,
            ),
          ),
          if (widget.node.text != null && widget.node.text!.isNotEmpty)
            TextSpan(
              text: ' "${widget.node.text}"',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: textColor,
              ),
            ),
          if (widget.node.resourceId != null && widget.node.resourceId!.isNotEmpty)
            TextSpan(
              text: ' ${_shortResourceId(widget.node.resourceId!)}',
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

String _shortResourceId(String fullId) {
  final slashIndex = fullId.lastIndexOf('/');
  return slashIndex >= 0 ? fullId.substring(slashIndex + 1) : fullId;
}