import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../services/device_manager.dart';
import 'statusbar_screenshot_service.dart';

class StatusbarScreenshotView extends StatefulWidget {
  const StatusbarScreenshotView({super.key});

  @override
  State<StatusbarScreenshotView> createState() => _StatusbarScreenshotViewState();
}

class _StatusbarScreenshotViewState extends State<StatusbarScreenshotView> {
  Timer? _timer;
  String? _imagePath;
  bool _loading = false;
  String? _error;

  ui.Image? _rawImage;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  int? _statusBarHeight;
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  void _resolveImage(String path) {
    final provider = FileImage(File(path));
    final stream = provider.resolve(const ImageConfiguration());
    _removeImageListener();
    _imageStream = stream;
    _imageListener = ImageStreamListener(
      (imageInfo, _) {
        if (mounted) {
          setState(() {
            _rawImage = imageInfo.image;
          });
        }
      },
      onError: (e, st) {
        if (mounted) {
          setState(() {
            _error = 'Failed to load image structure: $e';
          });
        }
      },
    );
    stream.addListener(_imageListener!);
  }

  Future<void> _refresh() async {
    if (_loading) return;
    final deviceId = context.read<DeviceManager>().selected?.id;
    if (deviceId == null) {
      if (mounted) {
        setState(() {
          _error = 'No device connected';
          _imagePath = null;
          _rawImage = null;
        });
      }
      return;
    }

    setState(() => _loading = true);

    if (_imagePath != null) {
      PaintingBinding.instance.imageCache.evict(FileImage(File(_imagePath!)));
    }

    final shouldFetchHeight = _statusBarHeight == null || (_refreshCount % 3 == 0);
    _refreshCount++;

    int? newHeight = _statusBarHeight;
    if (shouldFetchHeight) {
      newHeight = await StatusbarScreenshotService.getStatusBarHeight(deviceId);
    }

    final path = await StatusbarScreenshotService.capture(deviceId);

    if (mounted) {
      setState(() {
        _loading = false;
        _imagePath = path;
        _statusBarHeight = newHeight;
        _error = path == null ? 'Failed to capture screenshot' : null;
      });
      if (path != null) {
        _resolveImage(path);
      } else {
        setState(() {
          _rawImage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _rawImage == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final double activeHeight = _statusBarHeight?.toDouble() ?? (_rawImage?.height.toDouble() ?? 100.0) * 0.04;

    return Column(
      children: [
        if (_loading)
          const LinearProgressIndicator(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _rawImage != null
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _rawImage!.width.toDouble() / activeHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _StatusbarPreviewPainter(
                            rawImage: _rawImage!,
                            statusBarHeight: activeHeight,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _StatusbarPreviewPainter extends CustomPainter {
  final ui.Image rawImage;
  final double statusBarHeight;

  _StatusbarPreviewPainter({
    required this.rawImage,
    required this.statusBarHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imgW = rawImage.width.toDouble();
    final imgH = rawImage.height.toDouble();

    final cropLeft = 0.0;
    final cropTop = 0.0;
    final cropRight = imgW;
    final cropBottom = statusBarHeight.clamp(0.0, imgH);
    final cropW = cropRight - cropLeft;
    final cropH = cropBottom - cropTop;

    if (cropW <= 0 || cropH <= 0) return;

    final srcRect = Rect.fromLTWH(cropLeft, cropTop, cropW, cropH);
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(rawImage, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(_StatusbarPreviewPainter oldDelegate) {
    return oldDelegate.rawImage != rawImage || oldDelegate.statusBarHeight != statusBarHeight;
  }
}

