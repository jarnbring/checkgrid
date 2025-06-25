import 'package:flutter/material.dart';
import 'dart:math' as math;

class Background extends StatelessWidget {
  final Widget child;

  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(), // Fyll hela ytan!
      child: CustomPaint(painter: _GridPainter(), child: child),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A1A2F),
    );

    const double cellSize = 60.0;
    final double yStep = cellSize / math.sqrt2; // ~42.4

    int row = 0;
    // börja på första centret och loopa över centerY direkt
    for (
      double centerY = cellSize / 2;
      centerY < size.height + cellSize;
      centerY += yStep, row++
    ) {
      int col = 0;
      for (double x = 0; x < size.width + cellSize; x += cellSize, col++) {
        final offsetX = (row % 2 == 0) ? 0.0 : cellSize / 2;
        final isAlt = ((col + row) % 2 == 0);
        final baseColor =
            isAlt
                ? const Color.fromARGB(255, 23, 51, 80)
                : const Color.fromARGB(255, 13, 30, 48);

        final centerX = x + offsetX + cellSize / 2;

        canvas.save();
        canvas.translate(centerX, centerY);
        canvas.rotate(math.pi / 4);

        final rect = RRect.fromLTRBR(
          -cellSize / 2,
          -cellSize / 2,
          cellSize / 2,
          cellSize / 2,
          const Radius.circular(5),
        );

        // skugga
        final shadowPaint =
            Paint()
              ..color = Colors.black.withAlpha(255)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawRRect(rect.shift(const Offset(-2, -2)), shadowPaint);

        // själva rutan
        final paint = Paint()..color = baseColor;
        canvas.drawRRect(rect, paint);

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
