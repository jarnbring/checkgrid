import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSelectionPage extends StatefulWidget {
  final void Function(ThemeMode themeMode) onThemeChanged;
  final ThemeMode? themeMode;

  const ThemeSelectionPage({super.key, required this.onThemeChanged, required this.themeMode});

  @override
  ThemeSelectionPageState createState() => ThemeSelectionPageState();
}

class ThemeSelectionPageState extends State<ThemeSelectionPage> {
  ThemeMode? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.themeMode;
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', themeMode.toString());
  }

  void _onThemeChanged(ThemeMode themeMode) {
    setState(() {
      _selectedTheme = themeMode;
    });
    widget.onThemeChanged(themeMode);
    _saveThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Select Theme',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Light Mode'),
            value: _selectedTheme == ThemeMode.light,
            activeTrackColor: Colors.lightBlue,
            onChanged: (bool value) {
              _onThemeChanged(ThemeMode.light);
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _selectedTheme == ThemeMode.dark,
            activeTrackColor: Colors.lightBlue,
            onChanged: (bool value) {
              _onThemeChanged(ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}
