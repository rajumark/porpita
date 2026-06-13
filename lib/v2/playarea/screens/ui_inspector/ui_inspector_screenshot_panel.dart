import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiInspectorScreenshotPanel extends StatefulWidget {
  final String? screenshotPath;
  final String? error;
  final int screenshotVersion;
  final List<Rect> boundsOverlays;

  const UiInspectorScreenshotPanel({
    super.key,
    required this.screenshotPath,
    this.error,
    this.screenshotVersion = 0,
    this.boundsOverlays = const [],
  });

  @override
  State<UiInspectorScreenshotPanel> createState() => _UiInspectorScreenshotPanelState();
}

class _UiInspectorScreenshotPanelState extends State<UiInspectorScreenshotPanel> {
  ui.Image? _rawImage;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

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
    if (widget.screenshotPath == null || widget.screenshotPath!.isEmpty) {
      return const Center(child: Text('No screenshot'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          maxScale: 5.0,
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
                if (_rawImage != null && widget.boundsOverlays.isNotEmpty)
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _BoundsOverlayPainter(
                      rawImage: _rawImage!,
                      boundsList: widget.boundsOverlays,
                    ),
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
    );
  }
}

class _BoundsOverlayPainter extends CustomPainter {
  final ui.Image rawImage;
  final List<Rect> boundsList;

  _BoundsOverlayPainter({required this.rawImage, required this.boundsList});

  @override
  void paint(Canvas canvas, Size size) {
    if (boundsList.isEmpty) return;

    final imgW = rawImage.width.toDouble();
    final imgH = rawImage.height.toDouble();

    final scaleX = size.width / imgW;
    final scaleY = size.height / imgH;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final displayW = imgW * scale;
    final displayH = imgH * scale;
    final offsetX = (size.width - displayW) / 2;
    final offsetY = (size.height - displayH) / 2;

    final fillPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final bounds in boundsList) {
      final left = offsetX + bounds.left * scale;
      final top = offsetY + bounds.top * scale;
      final right = offsetX + bounds.right * scale;
      final bottom = offsetY + bounds.bottom * scale;

      final rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_BoundsOverlayPainter oldDelegate) {
    return oldDelegate.boundsList != boundsList || oldDelegate.rawImage != rawImage;
  }
}