import 'package:flutter/material.dart';

class NewWidget extends StatelessWidget {
  const NewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -40 / 2,
      left: 0,
      width: 80,
      height: 30,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(80, 30),
            painter: _LabelBorderPainter(borderWidth: 4),
          ),
          ClipPath(
            clipper: _LabelClipper(),
            child: Container(
              color: const Color.fromARGB(255, 11, 181, 16),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Antonio',
                      fontWeight: FontWeight.w900,
                      foreground:
                          Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.black,
                    ),
                  ),
                  const Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Antonio',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelBorderPainter extends CustomPainter {
  final double borderWidth;
  _LabelBorderPainter({required this.borderWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = const Color.fromARGB(255, 0, 0, 0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;
    final double rectWidth = size.width * 0.7;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(rectWidth, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(rectWidth, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LabelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double rectWidth = size.width * 0.7;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(rectWidth, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(rectWidth, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
