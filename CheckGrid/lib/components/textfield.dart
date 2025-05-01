import 'package:flutter/material.dart';

class InputFieldOutsideApp extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String? fontFamily;
  final IconData icon;
  final double? fontSize;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;

  const InputFieldOutsideApp({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.keyboardType,
    required this.obscureText,
    required this.controller,
    this.validator,
    this.fontFamily,
    this.fontSize,
    this.onTap,
  });

  @override
  State<InputFieldOutsideApp> createState() => _InputFieldOutsideAppState();
}

class _InputFieldOutsideAppState extends State<InputFieldOutsideApp> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
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
              color: _errorText != null
                  ? const Color.fromARGB(255, 255, 0, 0)
                  : Colors.white,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 60,
          child: FormField<String>(
            builder: (FormFieldState<String> field) {
              return TextField(
                onTap: widget.onTap,
                controller: widget.controller,
                autofocus: true,
                autocorrect: true,
                obscureText: widget.obscureText,
                cursorColor: Colors.white,
                keyboardType: widget.keyboardType,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontFamily: widget.fontFamily,
                ),
                onChanged: (value) {
                  setState(() {
                    _errorText = widget.validator?.call(value);
                    field.didChange(value);
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 14),
                  prefixIcon: Icon(widget.icon, color: Colors.white),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontFamily: widget.fontFamily,
                  ),
                ),
              );
            },
            validator: widget.validator,
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