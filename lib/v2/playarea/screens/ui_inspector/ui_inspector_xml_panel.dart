import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui_inspector_controller.dart';
import 'xml_tree_model.dart';
import 'xml_tree_widget.dart';

class UiInspectorXmlPanel extends StatefulWidget {
  final UiInspectorController controller;
  final String xmlContent;

  const UiInspectorXmlPanel({
    super.key,
    required this.controller,
    required this.xmlContent,
  });

  @override
  State<UiInspectorXmlPanel> createState() => _UiInspectorXmlPanelState();
}

class _UiInspectorXmlPanelState extends State<UiInspectorXmlPanel> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  int? _blinkFlatIndex;

  static const _filters = [
    ('clickable', Icons.touch_app),
    ('scrollable', Icons.swipe),
    ('enabled', Icons.check_circle_outline),
    ('focused', Icons.center_focus_strong),
    ('checked', Icons.check_box),
  ];

  void _jumpToFocused() {
    final focused = widget.controller.focusedNode;
    if (focused == null) return;

    final ancestors = widget.controller.treeModel?.getAncestorFlatIndices(focused.flatIndex);
    if (ancestors != null) {
      for (final idx in ancestors) {
        widget.controller.expandedNodes.add(idx);
      }
    }
    widget.controller.selectNode(focused.flatIndex);

    setState(() {
      _blinkFlatIndex = focused.flatIndex;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _blinkFlatIndex == focused.flatIndex) {
        setState(() {
          _blinkFlatIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treeModel = widget.controller.treeModel;

    if (treeModel == null) {
      return const Center(child: Text('Failed to parse XML'));
    }

    return Column(
      children: [
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            if (widget.controller.isSearchMode) {
              return _buildSearchBar();
            }
            return _buildActionRow(context, treeModel);
          },
        ),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) => _buildFilterChips(context),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              if (widget.controller.isSearchMode && widget.controller.searchQuery.isNotEmpty) {
                return _buildSearchResults(treeModel);
              }
              return XmlTreeWidget(
                treeModel: treeModel,
                expandedNodes: widget.controller.expandedNodes,
                highlightedIndices: widget.controller.highlightedIndices,
                onToggleExpand: widget.controller.toggleExpand,
                onNodeSelected: widget.controller.selectNode,
                focusedFlatIndex: _blinkFlatIndex,
                selectedFlatIndex: widget.controller.selectedFlatIndex,
              );
            },
          ),
        ),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) => _buildViewSummary(treeModel),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context, XmlTreeModel treeModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.search, size: 18),
          tooltip: 'Search',
          visualDensity: VisualDensity.compact,
          onPressed: () {
            widget.controller.enterSearchMode();
            _searchFocusNode.requestFocus();
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          tooltip: 'More actions',
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'expand',
              child: Text(widget.controller.isAllExpanded ? 'Collapse all' : 'Expand all'),
            ),
            const PopupMenuItem(value: 'copy', child: Text('Copy XML')),
            PopupMenuItem(
              value: 'jump_focus',
              enabled: widget.controller.focusedNode != null,
              child: const Text('Jump to focused element'),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'expand':
                widget.controller.toggleExpandAll();
                break;
              case 'copy':
                Clipboard.setData(ClipboardData(text: widget.xmlContent));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('XML copied'), duration: Duration(seconds: 1)),
                );
                break;
              case 'jump_focus':
                _jumpToFocused();
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final controller = widget.controller;
    final hasActive = controller.activeFilters.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          for (final (filter, icon) in _filters)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FilterChip(
                label: Text(filter, style: const TextStyle(fontSize: 11)),
                avatar: Icon(icon, size: 12),
                selected: controller.isFilterActive(filter),
                onSelected: (_) => controller.toggleFilter(filter),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedColor: colorScheme.primaryContainer,
              ),
            ),
          if (hasActive)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: ActionChip(
                label: const Text('Clear', style: TextStyle(fontSize: 11)),
                avatar: const Icon(Icons.close, size: 12),
                onPressed: () {
                  controller.toggleFilter(controller.activeFilters.first);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewSummary(XmlTreeModel treeModel) {
    final counts = treeModel.getViewTypeCounts();
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    if (top.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: top.map((e) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            '${e.value} ${e.key}',
            style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: colorScheme.onSurfaceVariant),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final resultCount = widget.controller.searchResults.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Icon(Icons.search, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: colorScheme.onSurface),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                hintText: 'Search id, text, class...',
                hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                widget.controller.updateSearch(value);
              },
            ),
          ),
          if (widget.controller.searchQuery.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              '$resultCount',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Close search',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              _searchController.clear();
              widget.controller.exitSearchMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(XmlTreeModel treeModel) {
    final results = widget.controller.searchResults;
    final colorScheme = Theme.of(context).colorScheme;
    final highlightedIndices = widget.controller.highlightedIndices;
    final selectedIndex = widget.controller.selectedFlatIndex;

    if (results.isEmpty) {
      return Center(
        child: Text('No results', style: TextStyle(color: colorScheme.onSurfaceVariant)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final node = results[index];
        final isHighlighted = highlightedIndices.contains(node.flatIndex);
        final isSelected = selectedIndex == node.flatIndex;
        final indent = node.depth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(left: indent * 18.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.green.withValues(alpha: 0.2)
                : (isHighlighted
                    ? colorScheme.secondaryContainer
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? Colors.green
                  : (isHighlighted
                      ? colorScheme.secondary
                      : Colors.transparent),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () => widget.controller.selectSearchResult(node.flatIndex),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    node.hasChildren ? Icons.subdirectory_arrow_right : Icons.label,
                    size: 14,
                    color: isSelected
                        ? Colors.green.shade700
                        : (isHighlighted
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.primary),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      node.displayLabel,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: isSelected
                            ? Colors.green.shade900
                            : (isHighlighted
                                ? colorScheme.onSecondaryContainer
                                : colorScheme.onSurface),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (node.isFocused) _buildFocusedDot(),
                ],
              ),
            ),
          ),
        );
      },
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
}