import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final Widget child;

  const GridBackground({super.key, required this.child});

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
    const double cellSize = 60.0;
    final paint =
        Paint()
          ..color = const Color(0xFF102840) // mörkblå ruta
          ..style = PaintingStyle.fill;

    final altPaint =
        Paint()
          ..color = const Color.fromARGB(255, 20, 50, 74); // ljusare blå ruta

    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        final isAlt = ((x / cellSize) + (y / cellSize)) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          isAlt ? paint : altPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
