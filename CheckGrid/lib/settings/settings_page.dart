import 'package:flutter/material.dart';
import 'package:gamename/components/group_settings.dart';
import 'package:gamename/components/icon_widget.dart';
import 'package:gamename/providers/settings_provider.dart';
import 'package:gamename/settings/privacy_policy.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool tempDarkmode = false;
  bool tempVibration = false;
  bool tempSound = false;
  bool tempNotificationReminder = false;
  bool tempClearCache = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings', style: TextStyle(fontSize: 20)),
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
                _buildGlossEffect(),
                _buildVibration(),
                //_buildClearCache(),
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
      secondary:
          context.watch<SettingsProvider>().isDarkMode
              ? IconWidget(icon: Icons.dark_mode)
              : IconWidget(icon: Icons.light_mode),
      value: context.watch<SettingsProvider>().isDarkMode,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        context.read<SettingsProvider>().setDarkMode(value);
      },
    );
  }

Widget _buildGlossEffect() {
  return SwitchListTile(
    title: const Text('Gloss effect'),
    secondary: IconWidget(icon: Icons.aspect_ratio),
    value: Provider.of<SettingsProvider>(context).useGlossEffect, // Använd SettingsProvider
    activeTrackColor: Colors.lightBlue,
    onChanged: (bool value) {
      Provider.of<SettingsProvider>(context, listen: false).toggleGlossEffect();
    },
  );
}

  Widget _buildVibration() {
    return SwitchListTile(
      title: const Text('Vibrations'),
      secondary:
          context.watch<SettingsProvider>().isVibrationOn
              ? IconWidget(icon: Icons.vibration)
              : IconWidget(icon: Icons.phone_iphone),
      value: context.watch<SettingsProvider>().isVibrationOn,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        setState(() {
          context.read<SettingsProvider>().setVibration(value);
        });
      },
    );
  }

  Widget _buildClearCache() {
    return ListTile(
      title: const Text('Clear cache'),
      leading: IconWidget(icon: Icons.cached),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).iconTheme.color?.withAlpha(100),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Clear Cache'),
              content: const Text(
                'Are you sure you want to clear the cache? All your settings will reset to default and the app will restart.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Stäng dialogen (Cancel)
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Stäng dialogen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyPage(),
                      ),
                    );
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPrivacyPolicy() {
    return ListTile(
      title: const Text('Privacy Policy'),
      leading: IconWidget(icon: Icons.privacy_tip_outlined),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).iconTheme.color?.withAlpha(100),
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
      secondary:
          tempSound
              ? IconWidget(icon: Icons.volume_up)
              : IconWidget(icon: Icons.volume_off),
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
      secondary: IconWidget(icon: Icons.format_bold),
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
      secondary:
          tempNotificationReminder
              ? IconWidget(icon: Icons.notifications_on)
              : IconWidget(icon: Icons.notifications_off),
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
