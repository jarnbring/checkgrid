import 'package:flutter/material.dart';
import 'package:CheckGrid/components/group_settings.dart';
import 'package:CheckGrid/components/icon_widget.dart';
import 'package:CheckGrid/providers/settings_provider.dart';
import 'package:CheckGrid/settings/noti_service.dart';
import 'package:CheckGrid/settings/privacy_policy.dart';
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
                _buildDarkPieces(),
                _buildGlossEffect(),
                _buildVibration(),
                _buildPrivacyPolicy(),
              ],
            ),
            GroupSettingsWidget(header: "Sound", children: [_buildSound()]),
            GroupSettingsWidget(header: "Text", children: [_buildBoldText()]),
            GroupSettingsWidget(
              header: "Notifications",
              children: [_buildNotificationReminder()],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Send notification now
                ElevatedButton(
                  onPressed: () async {
                    NotiService().showNotification(
                      title: "CheckGrid",
                      body: "Come back baby, I miss you <3",
                      settingsProvider: SettingsProvider(),
                    );
                  },
                  child: const Text("Send notification"),
                ),
                // Send scheduled notification
                ElevatedButton(
                  onPressed: () async {
                    NotiService().scheduleNotification(
                      title: "We miss you",
                      body:
                          "Come back on and keep highering your personal best!",
                      hour: 23,
                      minute: 55,
                      settingsProvider: SettingsProvider(),
                    );
                  },
                  child: const Text("Send delayed notification"),
                ),
              ],
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
      secondary: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
        child:
            context.watch<SettingsProvider>().isDarkMode
                ? IconWidget(key: ValueKey('dark'), icon: Icons.dark_mode)
                : IconWidget(key: ValueKey('light'), icon: Icons.light_mode),
      ),
      value: context.watch<SettingsProvider>().isDarkMode,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        context.read<SettingsProvider>().setDarkMode(value);
      },
    );
  }

  Widget _buildDarkPieces() {
    return SwitchListTile(
      title: const Text('Dark Pieces'),
      secondary: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
        child:
            context.watch<SettingsProvider>().isDarkPieces
                ? IconWidget(key: ValueKey('dark'), icon: Icons.dark_mode)
                : IconWidget(key: ValueKey('light'), icon: Icons.light_mode),
      ),
      value: context.watch<SettingsProvider>().isDarkPieces,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        context.read<SettingsProvider>().setDarkPieces(value);
      },
    );
  }

  Widget _buildGlossEffect() {
    return SwitchListTile(
      title: const Text('Gloss effect'),
      secondary: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
        child:
            Provider.of<SettingsProvider>(context).useGlossEffect
                ? IconWidget(
                  key: ValueKey('gloss_on'),
                  icon: Icons.aspect_ratio,
                )
                : IconWidget(
                  key: ValueKey('gloss_off'),
                  icon: Icons.fit_screen_sharp,
                ),
      ),
      value: Provider.of<SettingsProvider>(context).useGlossEffect,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        Provider.of<SettingsProvider>(
          context,
          listen: false,
        ).toggleGlossEffect();
      },
    );
  }

  Widget _buildVibration() {
    return SwitchListTile(
      title: const Text('Vibrations'),
      secondary: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
        child:
            context.watch<SettingsProvider>().isVibrationOn
                ? IconWidget(
                  key: ValueKey('vibration_on'),
                  icon: Icons.vibration,
                )
                : IconWidget(
                  key: ValueKey('vibration_off'),
                  icon: Icons.phone_iphone,
                ),
      ),
      value: context.watch<SettingsProvider>().isVibrationOn,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        setState(() {
          context.read<SettingsProvider>().setVibration(value);
        });
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
        );
      },
    );
  }

  // Sound
  Widget _buildSound() {
    return SwitchListTile(
      title: const Text('Sound'),
      secondary: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
        child:
            tempSound
                ? IconWidget(key: ValueKey('sound_on'), icon: Icons.volume_up)
                : IconWidget(
                  key: ValueKey('sound_off'),
                  icon: Icons.volume_off,
                ),
      ),
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
      secondary: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
        child:
            context.watch<SettingsProvider>().isBoldText
                ? IconWidget(key: ValueKey('bold_on'), icon: Icons.format_bold)
                : IconWidget(
                  key: ValueKey('bold_off'),
                  icon: Icons.format_clear,
                ),
      ),
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
      secondary: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
        child:
            context.watch<SettingsProvider>().notificationReminder
                ? IconWidget(
                  key: ValueKey('notif_on'),
                  icon: Icons.notifications_on,
                )
                : IconWidget(
                  key: ValueKey('notif_off'),
                  icon: Icons.notifications_off,
                ),
      ),
      value: context.watch<SettingsProvider>().notificationReminder,
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) {
        setState(() {
          context.read<SettingsProvider>().setNotificationReminder(value);
        });
      },
    );
  }
}
