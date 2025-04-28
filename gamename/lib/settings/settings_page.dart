import 'package:flutter/material.dart';
import 'package:gamename/components/group_settings.dart';
import 'package:gamename/components/icon_widget.dart';
import 'package:gamename/provider.dart';
import 'package:gamename/settings/privacy_policy.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  final void Function(ThemeMode themeMode) onThemeChanged;
  final ThemeMode? themeMode;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.themeMode,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ThemeMode? currentTheme;
  bool tempDarkmode = false;
  bool tempBoldText = false;
  bool tempVibration = false;
  bool tempSound = false;
  bool tempNotificationReminder = false;
  bool tempClearCache = false;

  @override
  void initState() {
    super.initState();
    currentTheme = widget.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
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
        child: Column(
          children: [
            GroupSettingsWidget(
              header: "General",
              children: [
                _buildDarkmode(),
                _buildVibration(),
                _buildClearCache(),
                _buildPrivacyPolicy(),
              ],
            ),
            GroupSettingsWidget(header: "Sound", children: [_buildSound()]),
            GroupSettingsWidget(header: "Text", children: [_buildBoldText()]),
            GroupSettingsWidget(
              header: "Notifications",
              children: [_buildNotificationReminder()],
            ),
          ],
        ),
      ),
    );
  }

  // General
  Widget _buildDarkmode() {
    return SwitchListTile(
      title: const Text('Darkmode'),
      secondary: IconWidget(
        icon: Icons.dark_mode,
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      value: tempDarkmode,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        setState(() {
          tempDarkmode = value;
        });
      },
    );
  }

  Widget _buildVibration() {
    return SwitchListTile(
      title: const Text('Vibrations'),
      secondary: IconWidget(
        icon: Icons.vibration_rounded,
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      value: tempVibration,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        setState(() {
          tempVibration = value;
        });
      },
    );
  }

  Widget _buildClearCache() {
    return SwitchListTile(
      title: const Text('Clear cache'),
      secondary: IconWidget(icon: Icons.cached, color: Colors.white),
      value: tempClearCache,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        setState(() {
          tempClearCache = value;
        });
      },
    );
  }

  Widget _buildPrivacyPolicy() {
    return ListTile(
      title: const Text('Privacy Policy'),
      leading: IconWidget(
        icon: Icons.privacy_tip_outlined,
        color: Colors.white,
      ),
      trailing: IconWidget(
        icon: Icons.arrow_forward_ios,
        color: Colors.transparent,
      ),
      onTap:
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
            ),
          },
    );
  }

  // Sound
  Widget _buildSound() {
    return SwitchListTile(
      title: const Text('Sound'),
      secondary: IconWidget(icon: Icons.volume_up, color: Colors.white),
      value: tempSound,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        setState(() {
          tempSound = value;
        });
      },
    );
  }

  // Text
  Widget _buildBoldText() {
  return SwitchListTile(
    title: const Text('Bold text'),
    secondary: IconWidget(icon: Icons.format_bold, color: Colors.white),
    value: context.watch<SettingsProvider>().isBoldText,
    activeTrackColor: Colors.lightBlue,
    onChanged: (bool value) {
      context.read<SettingsProvider>().setBoldText(value);
    },
  );
}

  // Notifications
  Widget _buildNotificationReminder() {
    return SwitchListTile(
      title: const Text('Reminder'),
      secondary: IconWidget(icon: Icons.notifications_on, color: Colors.white),
      value: tempNotificationReminder,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        setState(() {
          tempNotificationReminder = value;
        });
      },
    );
  }
}
