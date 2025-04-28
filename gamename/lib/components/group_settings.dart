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
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 14),
              Text(header, style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemCount: children.length,
            itemBuilder: (context, index) {
              return children[index];
            },
          ),
        ],
      ),
    );
  }
}
