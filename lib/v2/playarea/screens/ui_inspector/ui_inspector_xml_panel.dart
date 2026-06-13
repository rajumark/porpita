import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui_inspector_controller.dart';
import 'xml_tree_controls.dart';
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
            return AnimatedCrossFade(
              firstChild: XmlTreeControls(
                mode: widget.controller.mode,
                layersValue: widget.controller.layersValue,
                maxDepth: treeModel.maxDepth,
                layersNodeCount: widget.controller.highlightedIndices.length,
                focusValue: widget.controller.focusValue,
                totalNodes: treeModel.totalNodes,
                focusNodeLabel: treeModel.getNodeAtFlatIndex(widget.controller.focusValue)?.shortTag,
                onModeChanged: widget.controller.setMode,
                onLayersChanged: widget.controller.setLayersValue,
                onFocusChanged: widget.controller.setFocusValue,
              ),
              secondChild: _buildSearchBar(),
              crossFadeState: widget.controller.isSearchMode
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            );
          },
        ),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.controller.isSearchMode) ...[
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Close search',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _searchController.clear();
                      widget.controller.exitSearchMode();
                    },
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(widget.controller.isAllExpanded ? Icons.unfold_less : Icons.unfold_more, size: 18),
                    tooltip: widget.controller.isAllExpanded ? 'Collapse all' : 'Expand all',
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.controller.toggleExpandAll,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy XML',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.xmlContent));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('XML copied'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, size: 18),
                    tooltip: 'Search',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      widget.controller.enterSearchMode();
                      _searchFocusNode.requestFocus();
                    },
                  ),
                ],
              ],
            );
          },
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
              );
            },
          ),
        ),
      ],
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
                hintText: 'Search nodes...',
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
        ],
      ),
    );
  }

  Widget _buildSearchResults(XmlTreeModel treeModel) {
    final results = widget.controller.searchResults;
    final colorScheme = Theme.of(context).colorScheme;
    final highlightedIndices = widget.controller.highlightedIndices;

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
        final indent = node.depth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(left: indent * 18.0),
          decoration: BoxDecoration(
            color: isHighlighted ? colorScheme.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isHighlighted ? colorScheme.secondary : Colors.transparent,
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
                    color: isHighlighted ? colorScheme.onSecondaryContainer : colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      node.displayLabel,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: isHighlighted ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}