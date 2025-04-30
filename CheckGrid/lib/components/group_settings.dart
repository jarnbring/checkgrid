import 'package:flutter/material.dart';

class GroupSettingsWidget extends StatelessWidget {
  final String header;
  final List<Widget> children;

  const GroupSettingsWidget({
    super.key,
    required this.header,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromARGB(59, 158, 158, 158),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 14),
                Text(header, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 5),
            ...children,
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
