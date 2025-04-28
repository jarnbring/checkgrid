import 'package:flutter/material.dart';
import 'package:gamename/pages/theme_seleciton.dart';

class SettingsPage extends StatelessWidget {
  final void Function(ThemeMode themeMode) onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('Appearance'),
                subtitle: Text("Lightmode, Darkmode"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ThemeSelectionPage(
                            onThemeChanged: onThemeChanged,
                          ),
                    ),
                  );
                },
              ),
              const Divider(),
            ],
          ),
        ),
      );
  }
}
