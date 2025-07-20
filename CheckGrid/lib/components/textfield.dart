import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputFieldOutsideApp extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String? fontFamily;
  final IconData icon;
  final double? fontSize;
  final TextInputType keyboardType;
  final bool? obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool showError;

  const InputFieldOutsideApp({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.keyboardType,
    required this.controller,
    this.obscureText,
    this.validator,
    this.fontFamily,
    this.fontSize,
    this.onTap,
    this.showError = false, // Default är false
  });

  @override
  State<InputFieldOutsideApp> createState() => _InputFieldOutsideAppState();
}

class _InputFieldOutsideAppState extends State<InputFieldOutsideApp> {
  String? _errorText;

  @override
  void didUpdateWidget(InputFieldOutsideApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Uppdatera error text när showError ändras
    if (widget.showError != oldWidget.showError) {
      setState(() {
        if (widget.showError) {
          _errorText = widget.validator?.call(widget.controller.text);
        } else {
          _errorText = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontSize: widget.fontSize,
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontFamily: widget.fontFamily,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  _errorText != null
                      ? const Color.fromARGB(255, 255, 0, 0)
                      : textColor,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 60,
          child: TextFormField(
            onTap: widget.onTap,
            controller: widget.controller,
            //autocorrect: true,
            obscureText: widget.obscureText ?? false,
            cursorColor: CupertinoColors.systemBlue,
            keyboardType: widget.keyboardType,
            selectionControls: CupertinoTextSelectionControls(),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color,
              fontFamily: widget.fontFamily,
            ),
            onChanged: (value) {
              // Ta bara bort error om användaren rättar till det
              if (_errorText != null && widget.validator?.call(value) == null) {
                setState(() {
                  _errorText = null;
                });
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14),
              prefixIcon: Icon(widget.icon, color: textColor),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: textColor,
                fontFamily: widget.fontFamily,
              ),
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 0, 0),
                fontSize: widget.fontSize != null ? widget.fontSize! * 0.8 : 12,
                fontFamily: widget.fontFamily,
              ),
            ),
          ),
      ],
    );
  }
}
