import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool isPrice;
  final Color color;
  final String fontFamily;
  final TextAlign textAlign;
  final List<Shadow>? shadows;

  const OutlinedText({
    super.key,
    required this.text,
    this.fontSize = 22,
    this.isPrice = false,
    this.color = Colors.white,
    this.fontFamily = "Antonio",
    this.textAlign = TextAlign.start,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
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
          textAlign: textAlign,
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
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            shadows: shadows,
          ),
        ),
      ],
    );
  }
}
