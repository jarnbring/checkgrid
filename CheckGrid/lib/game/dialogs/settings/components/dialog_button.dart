import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DialogButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromARGB(255, 45, 190, 49),
        ),
        height: 50,
        width: 150,
        child: Center(
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
