import 'package:flutter/material.dart';
import 'dart:math' as math;

class Background extends StatelessWidget {
  final Widget child;
  final double cellSize;

  const Background({super.key, required this.child, this.cellSize = 80.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: CustomPaint(
        painter: _GridPainter(cellSize: cellSize),
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double cellSize;

  const _GridPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Colors
    final Color firstColor = const Color.fromARGB(255, 57, 117, 181);
    final Color secondColor = const Color.fromARGB(255, 38, 86, 137);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = secondColor,
    );

    final double yStep = cellSize / 2;
    int row = 0;

    // börja på första centret och loopa över centerY direkt
    for (
      double centerY = cellSize / 2;
      centerY <
          size.height + cellSize; // Lägg till cellSize för att täcka botten
      centerY += yStep, row++
    ) {
      final bool isOddRow = row % 2 == 1;
      final double startX = isOddRow ? -cellSize / 2 : 0.0;

      for (double x = startX; x < size.width; x += cellSize) {
        final isAlt = row % 2 == 0;
        Color baseColor = isAlt ? firstColor : secondColor;

        // Ändra färg på allra översta raden
        if (row == 0) {
          baseColor = const Color.fromARGB(255, 57, 117, 181);
        }

        final centerX = x + cellSize / 2;

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
              ..color = const Color.fromARGB(0, 70, 70, 70).withAlpha(255)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
        canvas.drawRRect(rect.shift(const Offset(-2, -2)), shadowPaint);

        // själva rutan
        final paint = Paint()..color = baseColor;
        canvas.drawRRect(rect, paint);

        canvas.restore();
      }
    }

    // Lägg till gradient-overlay sist
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final int alphaStrength = 160; // Max 255, min 0
    final Paint gradientPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(alphaStrength), // Mörk upptill
              Colors.transparent, // Ljusare i mitten
              Colors.black.withAlpha(alphaStrength), // Mörk nedtill
            ],
            stops: const [0.0, 0.41, 1.0],
          ).createShader(rect);
    canvas.drawRect(rect, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize;
}
