import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui_inspector_controller.dart';
import 'xml_tree_controls.dart';

class UiInspectorScreenshotPanel extends StatefulWidget {
  final String? screenshotPath;
  final String? error;
  final int screenshotVersion;
  final List<Rect> boundsOverlays;
  final Rect? selectedBoundsOverlay;
  final UiInspectorController controller;
  final VoidCallback? onNodeTap;

  const UiInspectorScreenshotPanel({
    super.key,
    required this.screenshotPath,
    required this.controller,
    this.error,
    this.screenshotVersion = 0,
    this.boundsOverlays = const [],
    this.selectedBoundsOverlay,
    this.onNodeTap,
  });

  @override
  State<UiInspectorScreenshotPanel> createState() => _UiInspectorScreenshotPanelState();
}

class _UiInspectorScreenshotPanelState extends State<UiInspectorScreenshotPanel> {
  ui.Image? _rawImage;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveImage());
  }

  @override
  void didUpdateWidget(UiInspectorScreenshotPanel oldWidget) {
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
    _transformController.dispose();
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

  void _handleTap(BuildContext boxContext, Offset localPosition) {
    if (_rawImage == null) return;

    final box = boxContext.findRenderObject() as RenderBox;
    final size = box.size;
    final imgW = _rawImage!.width.toDouble();
    final imgH = _rawImage!.height.toDouble();

    final scaleX = size.width / imgW;
    final scaleY = size.height / imgH;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final displayW = imgW * scale;
    final displayH = imgH * scale;
    final offsetX = (size.width - displayW) / 2;
    final offsetY = (size.height - displayH) / 2;

    final imgX = (localPosition.dx - offsetX) / scale;
    final imgY = (localPosition.dy - offsetY) / scale;

    final flatIndex = widget.controller.findNodeAtPoint(imgX, imgY);
    if (flatIndex != null) {
      widget.controller.selectNode(flatIndex);
      widget.onNodeTap?.call();
    }
  }

  void _handleLongPress(Offset localPosition) async {
    if (_rawImage == null) return;

    final imgX = localPosition.dx.round().clamp(0, _rawImage!.width - 1);
    final imgY = localPosition.dy.round().clamp(0, _rawImage!.height - 1);

    final byteData = await _rawImage!.toByteData();
    if (byteData == null || !mounted) return;

    final pixels = byteData.buffer.asUint32List();
    final pixelIndex = imgY * _rawImage!.width + imgX;
    if (pixelIndex < 0 || pixelIndex >= pixels.length) return;

    final pixel = pixels[pixelIndex];
    final r = (pixel >> 16) & 0xFF;
    final g = (pixel >> 8) & 0xFF;
    final b = pixel & 0xFF;
    final hex = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

    Clipboard.setData(ClipboardData(text: hex));
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Color: $hex'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.screenshotPath == null || widget.screenshotPath!.isEmpty) {
      return const Center(child: Text('No screenshot'));
    }

    final treeModel = widget.controller.treeModel;

    return Column(
      children: [
        if (treeModel != null)
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              return XmlTreeControls(
                focusValue: widget.controller.focusValue,
                totalNodes: treeModel.totalNodes,
                focusNodeLabel: treeModel.getNodeAtFlatIndex(widget.controller.focusValue)?.shortTag,
                onFocusChanged: widget.controller.setFocusValue,
              );
            },
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return InteractiveViewer(
                maxScale: 5.0,
                transformationController: _transformController,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Image.file(
                          File(widget.screenshotPath!),
                          key: ValueKey('screenshot_${widget.screenshotVersion}'),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                'Failed to load screenshot: $error',
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_rawImage != null && (widget.boundsOverlays.isNotEmpty || widget.selectedBoundsOverlay != null))
                        CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _BoundsOverlayPainter(
                            rawImage: _rawImage!,
                            boundsList: widget.boundsOverlays,
                            selectedBounds: widget.selectedBoundsOverlay,
                          ),
                        ),
                      if (_rawImage != null)
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapDown: (details) {
                            final stackContext = context;
                            _handleTap(stackContext, details.localPosition);
                          },
                          onLongPressStart: (details) {
                            _handleLongPress(details.localPosition);
                          },
                        ),
                      if (widget.error != null)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Material(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber, size: 16, color: Theme.of(context).colorScheme.error),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.error!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 16, color: Theme.of(context).colorScheme.onErrorContainer),
                                    tooltip: 'Copy error',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: widget.error!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Error copied'), duration: Duration(seconds: 1)),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BoundsOverlayPainter extends CustomPainter {
  final ui.Image rawImage;
  final List<Rect> boundsList;
  final Rect? selectedBounds;

  _BoundsOverlayPainter({required this.rawImage, required this.boundsList, this.selectedBounds});

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedBounds == null && boundsList.isEmpty) return;

    final imgW = rawImage.width.toDouble();
    final imgH = rawImage.height.toDouble();

    final scaleX = size.width / imgW;
    final scaleY = size.height / imgH;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final displayW = imgW * scale;
    final displayH = imgH * scale;
    final offsetX = (size.width - displayW) / 2;
    final offsetY = (size.height - displayH) / 2;

    final greenFill = Paint()
      ..color = Colors.green.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final greenStroke = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (selectedBounds != null) {
      final rect = _mapRect(selectedBounds!, scale, offsetX, offsetY);
      canvas.drawRect(rect, greenFill);
      canvas.drawRect(rect, greenStroke);
      return;
    }

    final orangeFill = Paint()
      ..color = Colors.orange.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final orangeStroke = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final bounds in boundsList) {
      final rect = _mapRect(bounds, scale, offsetX, offsetY);
      canvas.drawRect(rect, orangeFill);
      canvas.drawRect(rect, orangeStroke);
    }
  }

  Rect _mapRect(Rect bounds, double scale, double offsetX, double offsetY) {
    return Rect.fromLTRB(
      offsetX + bounds.left * scale,
      offsetY + bounds.top * scale,
      offsetX + bounds.right * scale,
      offsetY + bounds.bottom * scale,
    );
  }

  @override
  bool shouldRepaint(_BoundsOverlayPainter oldDelegate) {
    return oldDelegate.boundsList != boundsList ||
        oldDelegate.selectedBounds != selectedBounds ||
        oldDelegate.rawImage != rawImage;
  }
}