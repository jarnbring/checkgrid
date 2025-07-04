import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  const OutlinedText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          '\$$text',
          style: TextStyle(
            fontSize: 30,
            foreground:
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Antonio',
          ),
        ),
        Text(
          '\$$text',
          style: const TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Antonio',
          ),
        ),
      ],
    );
  }
}
