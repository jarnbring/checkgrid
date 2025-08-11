import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogBackButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const DialogBackButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<DialogBackButton> createState() => _DialogBackButtonState();
}

class _DialogBackButtonState extends State<DialogBackButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SettingsProvider>().doVibration(1);
        widget.onPressed();
      },
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color:
                isPressed
                    ? const Color.fromARGB(255, 35, 160, 39)
                    : const Color.fromARGB(255, 45, 190, 49),
          ),
          height: 50,
          width: 150,
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              child: Text(widget.text),
            ),
          ),
        ),
      ),
    );
  }
}
