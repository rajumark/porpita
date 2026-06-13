import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ui_inspector_controller.dart';
import 'xml_tree_model.dart';

class UiInspectorPropertiesPanel extends StatefulWidget {
  final XmlNode? node;
  final VoidCallback onClose;
  final UiInspectorController controller;
  final String? screenshotPath;
  final int screenshotVersion;
  final double? density;

  const UiInspectorPropertiesPanel({
    super.key,
    required this.node,
    required this.onClose,
    required this.controller,
    required this.screenshotPath,
    this.screenshotVersion = 0,
    this.density,
  });

  @override
  State<UiInspectorPropertiesPanel> createState() => _UiInspectorPropertiesPanelState();
}

class _UiInspectorPropertiesPanelState extends State<UiInspectorPropertiesPanel> {
  ui.Image? _rawImage;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveImage());
  }

  @override
  void didUpdateWidget(UiInspectorPropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.screenshotVersion != oldWidget.screenshotVersion ||
        widget.screenshotPath != oldWidget.screenshotPath) {
      _rawImage = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveImage());
    }
  }

  @override
  void dispose() {
    _removeImageListener();
    super.dispose();
  }

  void _removeImageListener() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
      _imageStream = null;
      _imageListener = null;
    }
  }

  void _resolveImage() {
    if (widget.screenshotPath == null || widget.screenshotPath!.isEmpty) return;
    if (!mounted) return;

    final provider = FileImage(File(widget.screenshotPath!));
    final stream = provider.resolve(const ImageConfiguration());
    _removeImageListener();
    _imageStream = stream;
    _imageListener = ImageStreamListener(
      (imageInfo, _) {
        if (mounted) {
          setState(() => _rawImage = imageInfo.image);
        }
      },
      onError: (e, st) {},
    );
    stream.addListener(_imageListener!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final node = widget.node;

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
                onPressed: widget.onClose,
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (node.boundsRect != null && _rawImage != null) ...[
                  _BoundsPreview(
                    bounds: node.boundsRect!,
                    rawImage: _rawImage!,
                  ),
                  const Divider(height: 1),
                ],
                if (node.boundsRect != null)
                  _SizeRow(bounds: node.boundsRect!, theme: theme, density: widget.density),
                ...node.attributes.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final attr = entry.value;
                  return _PropertyRow(
                    propKey: attr.key,
                    propValue: attr.value,
                    isEven: index.isEven,
                    theme: theme,
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}

class _BoundsPreview extends StatelessWidget {
  final Rect bounds;
  final ui.Image rawImage;

  const _BoundsPreview({required this.bounds, required this.rawImage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BoundsPreviewPainter(bounds: bounds, rawImage: rawImage),
      ),
    );
  }
}

class _BoundsPreviewPainter extends CustomPainter {
  final Rect bounds;
  final ui.Image rawImage;

  _BoundsPreviewPainter({required this.bounds, required this.rawImage});

  @override
  void paint(Canvas canvas, Size size) {
    final imgW = rawImage.width.toDouble();
    final imgH = rawImage.height.toDouble();

    final cropLeft = bounds.left.clamp(0.0, imgW);
    final cropTop = bounds.top.clamp(0.0, imgH);
    final cropRight = bounds.right.clamp(cropLeft, imgW);
    final cropBottom = bounds.bottom.clamp(cropTop, imgH);
    final cropW = cropRight - cropLeft;
    final cropH = cropBottom - cropTop;

    if (cropW <= 0 || cropH <= 0) return;

    final scaleX = size.width / cropW;
    final scaleY = size.height / cropH;
    final fitScale = scaleX < scaleY ? scaleX : scaleY;

    final displayW = cropW * fitScale;
    final displayH = cropH * fitScale;
    final offsetX = (size.width - displayW) / 2;
    final offsetY = (size.height - displayH) / 2;

    final srcRect = Rect.fromLTWH(cropLeft, cropTop, cropW, cropH);
    final dstRect = Rect.fromLTWH(offsetX, offsetY, displayW, displayH);

    canvas.drawImageRect(rawImage, srcRect, dstRect, Paint());

    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(dstRect, borderPaint);
  }

  @override
  bool shouldRepaint(_BoundsPreviewPainter oldDelegate) {
    return oldDelegate.bounds != bounds || oldDelegate.rawImage != rawImage;
  }
}

class _SizeRow extends StatelessWidget {
  final Rect bounds;
  final ThemeData theme;
  final double? density;

  const _SizeRow({required this.bounds, required this.theme, this.density});

  @override
  Widget build(BuildContext context) {
    final width = (bounds.right - bounds.left).round();
    final height = (bounds.bottom - bounds.top).round();
    String sizeText = '$width × $height px';
    if (density != null && density! > 0) {
      final dpWidth = (width / density!).round();
      final dpHeight = (height / density!).round();
      sizeText += '  •  $dpWidth × $dpHeight dp';
    }
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.straighten, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            sizeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
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