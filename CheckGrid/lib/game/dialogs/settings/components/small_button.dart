import 'package:flutter/material.dart';

class SmallUpperButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isX;

  const SmallUpperButton({
    super.key,
    required this.onPressed,
    required this.isX,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(68, 0, 0, 0),
          ),
          padding: const EdgeInsets.all(5),
          child: Icon(
            isX ? Icons.close : Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
