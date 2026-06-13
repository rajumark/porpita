import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'xml_tree_model.dart';

class UiInspectorController extends ChangeNotifier {
  XmlTreeModel? _treeModel;
  final Set<int> _expandedNodes = {};
  final Set<int> _highlightedIndices = {};
  int _focusValue = 0;
  bool _isSearchMode = false;
  String _searchQuery = '';
  List<XmlNode> _searchResults = [];
  Set<int> _searchResultIndices = {};
  int? _selectedFlatIndex;
  final Set<String> _activeFilters = {};

  XmlTreeModel? get treeModel => _treeModel;
  Set<int> get expandedNodes => _expandedNodes;
  Set<int> get highlightedIndices => _highlightedIndices;
  int get focusValue => _focusValue;
  bool get isSearchMode => _isSearchMode;
  String get searchQuery => _searchQuery;
  List<XmlNode> get searchResults => _searchResults;
  Set<int> get searchResultIndices => _searchResultIndices;
  int? get selectedFlatIndex => _selectedFlatIndex;
  Set<String> get activeFilters => _activeFilters;

  XmlNode? get selectedNode {
    if (_treeModel == null || _selectedFlatIndex == null) return null;
    return _treeModel!.getNodeAtFlatIndex(_selectedFlatIndex!);
  }

  Rect? get selectedBounds {
    if (_treeModel == null || _selectedFlatIndex == null) return null;
    final node = _treeModel!.getNodeAtFlatIndex(_selectedFlatIndex!);
    return node?.boundsRect;
  }

  List<({int flatIndex, Rect bounds})> get allBoundsNodes {
    if (_treeModel == null) return [];
    final list = <({int flatIndex, Rect bounds})>[];
    _collectBounds(_treeModel!.root, list);
    return list;
  }

  void _collectBounds(XmlNode node, List<({int flatIndex, Rect bounds})> list) {
    final rect = node.boundsRect;
    if (rect != null) {
      list.add((flatIndex: node.flatIndex, bounds: rect));
    }
    for (final child in node.children) {
      _collectBounds(child, list);
    }
  }

  int? findNodeAtPoint(double x, double y) {
    final point = Offset(x, y);
    int? bestIndex;
    double bestArea = double.infinity;
    for (final entry in allBoundsNodes) {
      if (entry.bounds.contains(point)) {
        final area = entry.bounds.width * entry.bounds.height;
        if (area < bestArea) {
          bestArea = area;
          bestIndex = entry.flatIndex;
        }
      }
    }
    return bestIndex;
  }

  XmlNode? get focusedNode {
    if (_treeModel == null) return null;
    return _findFocused(_treeModel!.root);
  }

  XmlNode? _findFocused(XmlNode node) {
    if (node.isFocused) return node;
    for (final child in node.children) {
      final found = _findFocused(child);
      if (found != null) return found;
    }
    return null;
  }

  int? get focusedFlatIndex => focusedNode?.flatIndex;

  List<Rect> get highlightedBounds {
    if (_treeModel == null || _highlightedIndices.isEmpty) return [];
    final list = <Rect>[];
    for (final index in _highlightedIndices) {
      if (index == _selectedFlatIndex) continue;
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
    _selectedFlatIndex = null;
    _focusValue = 0;
    _isSearchMode = false;
    _searchQuery = '';
    _searchResults = [];
    _searchResultIndices = {};
    _activeFilters.clear();

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

  // --- Selection ---

  void selectNode(int flatIndex) {
    if (_selectedFlatIndex == flatIndex) return;
    _selectedFlatIndex = flatIndex;
    _highlightedIndices.clear();
    notifyListeners();
  }

  void goToParent() {
    if (_treeModel == null || _selectedFlatIndex == null) return;
    final ancestors = _treeModel!.getAncestorFlatIndices(_selectedFlatIndex!);
    if (ancestors.isNotEmpty) {
      selectNode(ancestors.last);
    }
  }

  void goToChild(int index) {
    if (_treeModel == null || _selectedFlatIndex == null) return;
    final node = _treeModel!.getNodeAtFlatIndex(_selectedFlatIndex!);
    if (node != null && node.hasChildren && index < node.children.length) {
      final target = node.children[index];
      for (final idx in _treeModel!.getAncestorFlatIndices(target.flatIndex)) {
        _expandedNodes.add(idx);
      }
      _expandedNodes.add(_selectedFlatIndex!);
      selectNode(target.flatIndex);
    }
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
    _selectedFlatIndex = null;
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
    if (_selectedFlatIndex == flatIndex) return;
    _selectedFlatIndex = flatIndex;
    notifyListeners();
  }

  // --- Focus / Filter ---

  void setFocusValue(int value) {
    _focusValue = value;
    _selectedFlatIndex = null;
    _activeFilters.clear();
    _applyFocusHighlight();
    notifyListeners();
  }

  void toggleFilter(String filter) {
    if (_activeFilters.contains(filter)) {
      _activeFilters.remove(filter);
    } else {
      _activeFilters.add(filter);
    }
    if (_activeFilters.isEmpty) {
      _highlightedIndices.clear();
      _selectedFlatIndex = null;
    } else {
      _selectedFlatIndex = null;
      _applyFilterHighlight();
    }
    notifyListeners();
  }

  bool isFilterActive(String filter) => _activeFilters.contains(filter);

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

  void _applyFilterHighlight() {
    if (_treeModel == null) return;
    _highlightedIndices.clear();
    _collectFilteredNodes(_treeModel!.root);
  }

  void _collectFilteredNodes(XmlNode node) {
    bool matches = true;
    for (final filter in _activeFilters) {
      switch (filter) {
        case 'clickable':
          if (!node.isClickable) matches = false;
          break;
        case 'scrollable':
          if (!node.isScrollable) matches = false;
          break;
        case 'enabled':
          if (!node.isEnabled) matches = false;
          break;
        case 'focused':
          if (!node.isFocused) matches = false;
          break;
        case 'checked':
          if (!node.isChecked) matches = false;
          break;
      }
    }
    if (matches) {
      _highlightedIndices.add(node.flatIndex);
    }
    for (final child in node.children) {
      _collectFilteredNodes(child);
    }
  }
}