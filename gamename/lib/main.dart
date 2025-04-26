import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gamename/pages/menu_page.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  final Color darkmodeBackgroundColor = const Color.fromARGB(255, 39, 39, 39);
  final Color darkmodeButtonBackgroundColor = const Color.fromARGB(255, 21, 21, 21);
  final Color darkmodeTextColor = Colors.white;
  final Color lightmodeBackgroundColor = Colors.white;
  final Color lightmodeTextColor = const Color.fromARGB(255, 39, 39, 39);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MenuPage(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: lightmodeTextColor),
          backgroundColor: lightmodeBackgroundColor,
          titleTextStyle: TextStyle(color: lightmodeTextColor),
        ),
        scaffoldBackgroundColor: lightmodeBackgroundColor,
        textTheme: TextTheme(bodyMedium: TextStyle(color: lightmodeTextColor)),
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: darkmodeTextColor),
          backgroundColor: darkmodeBackgroundColor,
          titleTextStyle: TextStyle(color: darkmodeTextColor),
        ),
        scaffoldBackgroundColor: darkmodeBackgroundColor,
        textTheme: TextTheme(bodyMedium: TextStyle(color: darkmodeTextColor)),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
