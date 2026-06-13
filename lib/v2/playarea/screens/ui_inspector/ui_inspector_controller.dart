import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'xml_tree_controls.dart';
import 'xml_tree_model.dart';

class UiInspectorController extends ChangeNotifier {
  XmlTreeModel? _treeModel;
  final Set<int> _expandedNodes = {};
  final Set<int> _highlightedIndices = {};
  XmlTreeMode _mode = XmlTreeMode.focus;
  int _layersValue = 0;
  int _focusValue = 0;
  bool _isSearchMode = false;
  String _searchQuery = '';
  List<XmlNode> _searchResults = [];
  Set<int> _searchResultIndices = {};

  XmlTreeModel? get treeModel => _treeModel;
  Set<int> get expandedNodes => _expandedNodes;
  Set<int> get highlightedIndices => _highlightedIndices;
  XmlTreeMode get mode => _mode;
  int get layersValue => _layersValue;
  int get focusValue => _focusValue;
  bool get isSearchMode => _isSearchMode;
  String get searchQuery => _searchQuery;
  List<XmlNode> get searchResults => _searchResults;
  Set<int> get searchResultIndices => _searchResultIndices;

  Rect? get selectedBounds {
    if (_treeModel == null || _highlightedIndices.isEmpty) return null;
    final node = _treeModel!.getNodeAtFlatIndex(_highlightedIndices.first);
    return node?.boundsRect;
  }

  List<Rect> get highlightedBounds {
    if (_treeModel == null || _highlightedIndices.isEmpty) return [];
    final list = <Rect>[];
    for (final index in _highlightedIndices) {
      final node = _treeModel!.getNodeAtFlatIndex(index);
      final rect = node?.boundsRect;
      if (rect != null) list.add(rect);
    }
    return list;
  }

  bool get isAllExpanded {
    if (_treeModel == null) return false;
    return _countExpandable(_treeModel!.root) <= _expandedNodes.length;
  }

  void parseTree(String? xmlContent) {
    if (xmlContent == null || xmlContent.isEmpty) {
      _treeModel = null;
      return;
    }

    _treeModel = XmlTreeModel.parse(xmlContent);
    _expandedNodes.clear();
    _highlightedIndices.clear();
    _layersValue = 0;
    _focusValue = 0;
    _isSearchMode = false;
    _searchQuery = '';
    _searchResults = [];
    _searchResultIndices = {};

    if (_treeModel != null) {
      _expandAll();
    }

    notifyListeners();
  }

  // --- Expand / Collapse ---

  void toggleExpand(int flatIndex) {
    if (_expandedNodes.contains(flatIndex)) {
      _expandedNodes.remove(flatIndex);
    } else {
      _expandedNodes.add(flatIndex);
    }
    notifyListeners();
  }

  void toggleExpandAll() {
    if (isAllExpanded) {
      _collapseAll();
    } else {
      _expandAll();
    }
    notifyListeners();
  }

  void expandToDepth(int depth) {
    if (_treeModel == null) return;
    _expandNodeToDepth(_treeModel!.root, depth);
  }

  // --- Selection ---

  void selectNode(int flatIndex) {
    _highlightedIndices
      ..clear()
      ..add(flatIndex);
    notifyListeners();
  }

  // --- Search ---

  void enterSearchMode() {
    _isSearchMode = true;
    _searchQuery = '';
    _searchResults = [];
    _searchResultIndices = {};
    notifyListeners();
  }

  void exitSearchMode() {
    _isSearchMode = false;
    _searchQuery = '';
    _searchResults = [];
    _searchResultIndices = {};
    notifyListeners();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    if (_treeModel == null || query.isEmpty) {
      _searchResults = [];
      _searchResultIndices = {};
    } else {
      _searchResults = _treeModel!.searchNodes(query);
      _searchResultIndices = _searchResults.map((n) => n.flatIndex).toSet();
      for (final node in _searchResults) {
        _expandedNodes.addAll(_treeModel!.getAncestorFlatIndices(node.flatIndex));
      }
    }
    notifyListeners();
  }

  void selectSearchResult(int flatIndex) {
    _highlightedIndices
      ..clear()
      ..add(flatIndex);
    notifyListeners();
  }

  // --- Mode / Highlight ---

  void setMode(XmlTreeMode mode) {
    _mode = mode;
    if (mode == XmlTreeMode.layers) {
      _applyLayersHighlight();
    } else {
      _applyFocusHighlight();
    }
    notifyListeners();
  }

  void setLayersValue(int value) {
    _layersValue = value;
    _applyLayersHighlight();
    notifyListeners();
  }

  void setFocusValue(int value) {
    _focusValue = value;
    _applyFocusHighlight();
    notifyListeners();
  }

  // --- Private helpers ---

  int _countExpandable(XmlNode node) {
    var count = node.hasChildren ? 1 : 0;
    for (final child in node.children) {
      count += _countExpandable(child);
    }
    return count;
  }

  void _expandAll() {
    if (_treeModel == null) return;
    _expandAllRecursive(_treeModel!.root);
  }

  void _expandAllRecursive(XmlNode node) {
    if (node.hasChildren) {
      _expandedNodes.add(node.flatIndex);
      for (final child in node.children) {
        _expandAllRecursive(child);
      }
    }
  }

  void _collapseAll() {
    _expandedNodes.clear();
    if (_treeModel != null) {
      _expandedNodes.add(_treeModel!.root.flatIndex);
    }
  }

  void _expandNodeToDepth(XmlNode node, int maxDepth) {
    if (node.depth >= maxDepth) return;
    if (node.hasChildren) {
      _expandedNodes.add(node.flatIndex);
      for (final child in node.children) {
        _expandNodeToDepth(child, maxDepth);
      }
    }
  }

  void _applyLayersHighlight() {
    if (_treeModel == null) return;
    expandToDepth(_layersValue + 1);
    _highlightedIndices
      ..clear()
      ..addAll(_treeModel!.getNodesAtDepth(_layersValue).map((n) => n.flatIndex));
  }

  void _applyFocusHighlight() {
    if (_treeModel == null) return;
    final node = _treeModel!.getNodeAtFlatIndex(_focusValue);
    if (node == null) return;

    final ancestors = _treeModel!.getAncestorFlatIndices(_focusValue);
    _expandedNodes.addAll(ancestors);
    _highlightedIndices
      ..clear()
      ..add(_focusValue);
  }
}
