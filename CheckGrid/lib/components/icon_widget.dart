import 'package:flutter/material.dart';

class IconWidget extends StatelessWidget {
  final IconData icon;

  const IconWidget({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: Icon(icon, color: Theme.of(context).iconTheme.color),
    );
  }
}
