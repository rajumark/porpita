import 'package:xml/xml.dart';

class XmlNode {
  final String tag;
  final String shortTag;
  final Map<String, String> attributes;
  final List<XmlNode> children;
  final int depth;
  final int flatIndex;

  const XmlNode({
    required this.tag,
    required this.shortTag,
    required this.attributes,
    required this.children,
    required this.depth,
    required this.flatIndex,
  });

  bool get hasChildren => children.isNotEmpty;

  String? get text => attributes['text'];
  String? get resourceId => attributes['resource-id'];
  String? get contentDesc => attributes['content-desc'];
  String? get className => attributes['class'];
  String? get bounds => attributes['bounds'];
  String? get packageName => attributes['package'];

  String get displayLabel {
    final parts = <String>[shortTag];
    if (text != null && text!.isNotEmpty) {
      parts.add('text="$text"');
    }
    if (resourceId != null && resourceId!.isNotEmpty) {
      parts.add('id="$resourceId"');
    }
    return parts.join(' ');
  }
}

class XmlTreeModel {
  final XmlNode root;
  final int maxDepth;
  final int totalNodes;

  const XmlTreeModel({
    required this.root,
    required this.maxDepth,
    required this.totalNodes,
  });

  static XmlTreeModel? parse(String xmlContent) {
    if (xmlContent.isEmpty) return null;

    try {
      final document = XmlDocument.parse(xmlContent);
      final rootElement = document.rootElement;
      var indexCounter = 0;

      XmlNode buildNode(XmlElement element, int depth) {
        final attrs = <String, String>{};
        for (final attr in element.attributes) {
          attrs[attr.name.local] = attr.value;
        }

        final children = <XmlNode>[];
        for (final child in element.childElements) {
          children.add(buildNode(child, depth + 1));
        }

        final flatIndex = indexCounter++;
        final fullTag = element.name.local;
        final shortTag = _shortClassName(attrs['class'] ?? fullTag);

        return XmlNode(
          tag: fullTag,
          shortTag: shortTag,
          attributes: attrs,
          children: children,
          depth: depth,
          flatIndex: flatIndex,
        );
      }

      final root = buildNode(rootElement, 0);
      return XmlTreeModel(
        root: root,
        maxDepth: _calcMaxDepth(root),
        totalNodes: indexCounter,
      );
    } catch (_) {
      return null;
    }
  }

  static String _shortClassName(String fullClassName) {
    final dotIndex = fullClassName.lastIndexOf('.');
    return dotIndex >= 0 ? fullClassName.substring(dotIndex + 1) : fullClassName;
  }

  static int _calcMaxDepth(XmlNode node) {
    if (node.children.isEmpty) return node.depth;
    var max = node.depth;
    for (final child in node.children) {
      final childMax = _calcMaxDepth(child);
      if (childMax > max) max = childMax;
    }
    return max;
  }

  List<XmlNode> getNodesAtDepth(int targetDepth) {
    final result = <XmlNode>[];
    _collectAtDepth(root, targetDepth, result);
    return result;
  }

  void _collectAtDepth(XmlNode node, int targetDepth, List<XmlNode> result) {
    if (node.depth == targetDepth) {
      result.add(node);
      return;
    }
    for (final child in node.children) {
      _collectAtDepth(child, targetDepth, result);
    }
  }

  XmlNode? getNodeAtFlatIndex(int index) {
    return _findByFlatIndex(root, index);
  }

  XmlNode? _findByFlatIndex(XmlNode node, int index) {
    if (node.flatIndex == index) return node;
    for (final child in node.children) {
      final found = _findByFlatIndex(child, index);
      if (found != null) return found;
    }
    return null;
  }

  List<int> getAncestorFlatIndices(int flatIndex) {
    final ancestors = <int>[];
    _findAncestors(root, flatIndex, ancestors);
    return ancestors;
  }

  bool _findAncestors(XmlNode node, int targetIndex, List<int> ancestors) {
    if (node.flatIndex == targetIndex) return true;
    for (final child in node.children) {
      if (_findAncestors(child, targetIndex, ancestors)) {
        ancestors.add(node.flatIndex);
        return true;
      }
    }
    return false;
  }
}
