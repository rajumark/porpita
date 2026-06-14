import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../services/device_manager.dart';
import 'statusbar_screenshot_service.dart';

class StatusbarScreenshotView extends StatefulWidget {
  final bool compact;
  final VoidCallback? onTap;

  const StatusbarScreenshotView({super.key, this.compact = false, this.onTap});

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

  StatusbarInfo? _statusBarInfo;
  bool? _lastIsLandscape;

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
            _error = 'Failed to load image: $e';
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
          _statusBarInfo = null;
          _lastIsLandscape = null;
        });
      }
      return;
    }

    setState(() => _loading = true);

    if (_imagePath != null) {
      PaintingBinding.instance.imageCache.evict(FileImage(File(_imagePath!)));
    }

    final results = await Future.wait([
      StatusbarScreenshotService.capture(deviceId),
      StatusbarScreenshotService.getStatusBarInfo(deviceId),
    ]);

    final path = results[0] as String?;
    final info = results[1] as StatusbarInfo?;

    if (path != null) {
      final pngInfo = _PngHeaderInfo.read(path);
      if (pngInfo != null) {
        _lastIsLandscape = pngInfo.width > pngInfo.height;
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
        _imagePath = path;
        _statusBarInfo = info;
        _error = path == null ? 'Failed to capture screenshot' : null;
      });
      if (path != null) {
        _resolveImage(path);
      } else {
        _rawImage = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    final noStatusBar = _statusBarInfo != null && !_statusBarInfo!.visible;

    return SizedBox(
      height: 32,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 32,
          padding: EdgeInsets.symmetric(horizontal: widget.onTap != null ? 0 : 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: noStatusBar || _rawImage == null || _statusBarInfo == null
              ? const SizedBox.shrink()
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    size: Size(_rawImage!.width.toDouble() * 32 / _statusBarInfo!.height, 32),
                    painter: _StatusbarPreviewPainter(
                      rawImage: _rawImage!,
                      statusBarHeight: _statusBarInfo!.height.toDouble(),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final noStatusBar = _statusBarInfo != null && !_statusBarInfo!.visible;

    if (noStatusBar) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'Status bar is hidden\n(Full-screen mode)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

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

    double activeHeight = _statusBarInfo?.height.toDouble() ?? (_rawImage?.height.toDouble() ?? 100.0) * 0.04;
    if (activeHeight <= 0) {
      activeHeight = 24.0;
    }

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

class _PngHeaderInfo {
  final int width;
  final int height;

  _PngHeaderInfo(this.width, this.height);

  static _PngHeaderInfo? read(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;
      final bytes = file.readAsBytesSync();
      if (bytes.length < 24) return null;
      if (bytes[0] != 0x89 || bytes[1] != 0x50 || bytes[2] != 0x4E || bytes[3] != 0x47) return null;
      final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
      final height = (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
      return _PngHeaderInfo(width, height);
    } catch (_) {
      return null;
    }
  }
}
