import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui_inspector_controller.dart';
import 'xml_tree_controls.dart';
import 'xml_tree_widget.dart';

class UiInspectorXmlPanel extends StatelessWidget {
  final UiInspectorController controller;
  final String xmlContent;

  const UiInspectorXmlPanel({
    super.key,
    required this.controller,
    required this.xmlContent,
  });

  @override
  Widget build(BuildContext context) {
    final treeModel = controller.treeModel;

    if (treeModel == null) {
      return const Center(child: Text('Failed to parse XML'));
    }

    return Column(
      children: [
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return XmlTreeControls(
              mode: controller.mode,
              layersValue: controller.layersValue,
              maxDepth: treeModel.maxDepth,
              layersNodeCount: controller.highlightedIndices.length,
              focusValue: controller.focusValue,
              totalNodes: treeModel.totalNodes,
              focusNodeLabel: treeModel.getNodeAtFlatIndex(controller.focusValue)?.shortTag,
              onModeChanged: controller.setMode,
              onLayersChanged: controller.setLayersValue,
              onFocusChanged: controller.setFocusValue,
            );
          },
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(controller.isAllExpanded ? Icons.unfold_less : Icons.unfold_more, size: 18),
                  tooltip: controller.isAllExpanded ? 'Collapse all' : 'Expand all',
                  visualDensity: VisualDensity.compact,
                  onPressed: controller.toggleExpandAll,
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy XML',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: xmlContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('XML copied'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return XmlTreeWidget(
                treeModel: treeModel,
                expandedNodes: controller.expandedNodes,
                highlightedIndices: controller.highlightedIndices,
                onToggleExpand: controller.toggleExpand,
                onNodeSelected: controller.selectNode,
              );
            },
          ),
        ),
      ],
    );
  }
}
