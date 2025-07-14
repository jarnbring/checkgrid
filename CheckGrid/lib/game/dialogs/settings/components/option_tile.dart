import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 32, 135, 219),
        ),
        child: ListTile(
          title: Text(title, style: const TextStyle(color: Colors.white)),
          leading: Icon(icon, color: Colors.white),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap:
              () => {context.read<SettingsProvider>().doVibration(1), onTap()},
        ),
      ),
    );
  }
}
