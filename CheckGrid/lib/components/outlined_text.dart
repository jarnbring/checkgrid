import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool isPrice;

  const OutlinedText({
    super.key,
    required this.text,
    this.fontSize = 22,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    final String fontFamily = 'Antonio';

    String temp;
    if (isPrice) {
      try {
        double value = double.parse(text);
        temp = value == 0.0 ? 'Free' : '\$$text';
      } catch (e) {
        temp = text;
      }
    } else {
      temp = text;
    }

    return Stack(
      children: [
        Text(
          temp,
          style: TextStyle(
            fontSize: fontSize,
            foreground:
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          temp,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }
}
