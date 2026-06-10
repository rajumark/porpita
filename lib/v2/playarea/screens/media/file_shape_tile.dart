import 'package:flutter/material.dart';
import 'file_categorizer.dart';

class FileShapeTile extends StatelessWidget {
  final String extension;
  final FileTypeStyle style;
  final double size;

  const FileShapeTile({
    super.key,
    required this.extension,
    required this.style,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final ext = extension.toUpperCase();
    final showExt = ext.isNotEmpty && ext.length <= 4;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FolderShapePainter(
                fill: style.background,
                stroke: style.foreground.withValues(alpha: 0.18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  style.category.icon,
                  size: size * 0.32,
                  color: style.foreground.withValues(alpha: 0.9),
                ),
                if (showExt) ...[
                  const SizedBox(height: 2),
                  Text(
                    ext,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: style.foreground,
                      fontSize: size * 0.16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderShapePainter extends CustomPainter {
  final Color fill;
  final Color stroke;
  _FolderShapePainter({required this.fill, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final w = size.width;
    final h = size.height;

    final path = Path();
    final tabW = w * 0.4;
    final tabH = h * 0.18;
    final cornerR = 6.0;

    path.moveTo(0, tabH + cornerR);
    path.quadraticBezierTo(0, tabH, cornerR, tabH);
    path.lineTo(tabW - cornerR, tabH);
    path.quadraticBezierTo(tabW, tabH, tabW, tabH + cornerR);
    path.lineTo(w - cornerR, 0);
    path.quadraticBezierTo(w, 0, w, cornerR);
    path.lineTo(w, h - cornerR);
    path.quadraticBezierTo(w, h, w - cornerR, h);
    path.lineTo(cornerR, h);
    path.quadraticBezierTo(0, h, 0, h - cornerR);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, outline);
  }

  @override
  bool shouldRepaint(covariant _FolderShapePainter old) =>
      old.fill != fill || old.stroke != stroke;
}
