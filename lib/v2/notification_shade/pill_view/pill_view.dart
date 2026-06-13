import 'package:flutter/material.dart';
import '../notification_shade_dialog.dart';

class PillView extends StatefulWidget {
  const PillView({super.key});

  @override
  State<PillView> createState() => _PillViewState();
}

class _PillViewState extends State<PillView> {
  final GlobalKey _pillKey = GlobalKey();

  void _onTap() {
    final renderBox = _pillKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final pillRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );

    NotificationShadeDialog.show(context, pillRect: pillRect);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: _pillKey,
        borderRadius: BorderRadius.circular(20),
        onTap: _onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Icon(Icons.airplanemode_on, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Icon(Icons.bluetooth, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Icon(Icons.hot_tub, size: 14, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
