import 'dart:io';
import 'package:flutter/material.dart';
import 'package:porpita/v2/playarea/screens/apps/icons/app_icon_service.dart';

class AppIcon extends StatelessWidget {
  final String packageName;
  final String deviceId;
  final double size;
  final Map<String, String>? iconPaths;

  const AppIcon({
    super.key,
    required this.packageName,
    required this.deviceId,
    this.size = 28,
    this.iconPaths,
  });

  @override
  Widget build(BuildContext context) {
    final path = iconPaths != null
        ? iconPaths![packageName]
        : AppIconService.instance.getIconPath(deviceId, packageName);

    if (path != null && path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.file(
          File(path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, e, _) => _defaultIcon(context),
        ),
      );
    }

    return _defaultIcon(context);
  }

  Widget _defaultIcon(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(
        Icons.android,
        size: size * 0.55,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}