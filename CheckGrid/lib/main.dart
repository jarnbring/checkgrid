// ignore_for_file: unused_import, slash_for_doc_comments

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:checkgrid/pages/menu_page.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:checkgrid/router.dart';
import 'package:checkgrid/settings/noti_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

/**
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    kReleaseMode
        ? MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => SettingsProvider()),
              ChangeNotifierProvider(create: (_) => GeneralProvider()),
            ],
            child: const MyApp(),
          )
        : DevicePreview(
            enabled: true,
            builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => SettingsProvider()),
                ChangeNotifierProvider(create: (_) => GeneralProvider()),
              ],
              child: const MyApp(),
            ),
          ),
  );
}
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure MobileAds
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['EMULATOR']),
  );
  await MobileAds.instance.initialize();

  // Load settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Initialisera NotificationService
  final notiService = NotiService();

  await notiService.initNotification();
  //await notiService.scheduleWeeklyRotatingNotifications(settingsProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Darkmode & Lightmode colors
  final Color darkmodeBackgroundColor = const Color.fromARGB(255, 39, 39, 39);
  final Color darkmodeTextColor = Colors.white;
  final Color dialogColor = Color.fromARGB(255, 83, 83, 83);
  final Color lightmodeBackgroundColor = Colors.white;
  final Color lightmodeTextColor = const Color.fromARGB(255, 39, 39, 39);

  @override
  void initState() {
    super.initState();
  }

  void setOrientations() {
    final generalProvider = context.watch<GeneralProvider>();
    bool isTablet = generalProvider.isTablet(context);

    // Set orientations depending on device
    SystemChrome.setPreferredOrientations(
      isTablet
          ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
          : [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ], // Only able to use portrait mode if on mobile
    );
  }

  @override
  Widget build(BuildContext context) {
    setOrientations();

    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: lightmodeTextColor),
          backgroundColor: lightmodeBackgroundColor,
          titleTextStyle: TextStyle(
            color: lightmodeTextColor,
            fontWeight:
                context.watch<SettingsProvider>().isBoldText
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
        dialogTheme: DialogThemeData(backgroundColor: lightmodeBackgroundColor),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(
              const Color.fromARGB(255, 189, 189, 189),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(
            color: lightmodeTextColor,
            fontSize: 16,
            fontWeight:
                context.watch<SettingsProvider>().isBoldText
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
        scaffoldBackgroundColor: lightmodeBackgroundColor,
        cardColor: lightmodeTextColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        iconTheme: IconThemeData(color: darkmodeBackgroundColor),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: lightmodeTextColor,
            fontWeight:
                context.watch<SettingsProvider>().isBoldText
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: darkmodeTextColor),
          backgroundColor: darkmodeBackgroundColor,
          titleTextStyle: TextStyle(
            color: darkmodeTextColor,
            fontWeight:
                context.watch<SettingsProvider>().isBoldText
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
        dialogTheme: DialogThemeData(backgroundColor: darkmodeBackgroundColor),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(
              const Color.fromARGB(255, 200, 200, 200),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(
            color: darkmodeTextColor,
            fontSize: 16,
            fontWeight:
                context.watch<SettingsProvider>().isBoldText
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
        scaffoldBackgroundColor: darkmodeBackgroundColor,
        cardColor: darkmodeTextColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        iconTheme: IconThemeData(color: lightmodeBackgroundColor),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: darkmodeTextColor,
            fontWeight:
                context.watch<SettingsProvider>().isBoldText
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
      ),
      themeMode: context.watch<SettingsProvider>().themeMode,
    );
  }
}
