import 'package:flutter/material.dart';
import 'package:checkgrid/components/group_settings.dart';
import 'package:checkgrid/components/icon_widget.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:checkgrid/pages/settings/noti_service.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GroupSettingsWidget(
              header: "General",
              children: [
                //_buildDarkmode(),
                _buildVibration(),
                _buildBoldText(),
              ],
            ),
            GroupSettingsWidget(header: "Sound", children: [_buildSound()]),
            GroupSettingsWidget(
              header: "Notifications",
              children: [_buildNotificationReminder()],
            ),
            GroupSettingsWidget(
              header: "Other",
              children: [
                _buildSocials(),
                _buildFeedback(),
                _buildPrivacyPolicy(),
              ],
            ),
            const SizedBox(height: 20),
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
  // Widget _buildDarkmode() {
  //   return SwitchListTile(
  //     title: const Text('Darkmode'),
  //     secondary: AnimatedSwitcher(
  //       duration: const Duration(milliseconds: 300),
  //       transitionBuilder:
  //           (child, animation) => FadeTransition(
  //             opacity: animation,
  //             child: ScaleTransition(scale: animation, child: child),
  //           ),
  //       child:
  //           context.watch<SettingsProvider>().isDarkMode
  //               ? IconWidget(key: ValueKey('dark'), icon: Icons.dark_mode)
  //               : IconWidget(key: ValueKey('light'), icon: Icons.light_mode),
  //     ),
  //     value: context.watch<SettingsProvider>().isDarkMode,
  //     activeTrackColor: Colors.lightBlue,
  //     onChanged: (bool value) {
  //       context.read<SettingsProvider>().setDarkMode(value);
  //     },
  //   );
  // }

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
        HapticFeedback.lightImpact();
        context.read<SettingsProvider>().setVibration(value);
      },
    );
  }

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
        context.read<SettingsProvider>().doVibration(1);
        context.read<SettingsProvider>().setBoldText(value);
      },
    );
  }

  // Sound - FIXAD VERSION
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
            context
                    .watch<SettingsProvider>()
                    .isSoundOn // ÄNDRAT: använder provider istället för tempSound
                ? IconWidget(key: ValueKey('sound_on'), icon: Icons.volume_up)
                : IconWidget(
                  key: ValueKey('sound_off'),
                  icon: Icons.volume_off,
                ),
      ),
      value:
          context
              .watch<SettingsProvider>()
              .isSoundOn, // ÄNDRAT: använder provider istället för tempSound
      activeTrackColor: Colors.lightBlue,
      onChanged: (bool value) async {
        // ÄNDRAT: gjorde async
        context.read<SettingsProvider>().doVibration(1);
        await context.read<SettingsProvider>().setSound(
          value,
        ); // ÄNDRAT: anropar setSound istället för setState
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
        context.read<SettingsProvider>().doVibration(1);
        context.read<SettingsProvider>().setNotificationReminder(value);
      },
    );
  }

  // Other
  Widget _buildSocials() {
    return ListTile(
      title: const Text('Socials'),
      leading: IconWidget(icon: Icons.account_circle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).iconTheme.color?.withAlpha(100),
      ),
      onTap:
          () => {
            context.read<SettingsProvider>().doVibration(1),
            context.pushNamed('/socials'),
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
            context.read<SettingsProvider>().doVibration(1),
            context.pushNamed('/privacy_policy'),
          },
    );
  }

  Widget _buildFeedback() {
    return ListTile(
      title: const Text('Feedback'),
      leading: IconWidget(icon: Icons.feedback_outlined),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).iconTheme.color?.withAlpha(100),
      ),
      onTap:
          () => {
            context.read<SettingsProvider>().doVibration(1),
            context.pushNamed('/feedback'),
          },
    );
  }
}
