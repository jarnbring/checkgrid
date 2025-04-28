import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gamename/pages/menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Color darkmodeBackgroundColor = const Color.fromARGB(255, 39, 39, 39);
  final Color darkmodeButtonBackgroundColor = const Color.fromARGB(
    255,
    21,
    21,
    21,
  );
  final Color darkmodeTextColor = Colors.white;
  final Color lightmodeBackgroundColor = Colors.white;
  final Color lightmodeTextColor = const Color.fromARGB(255, 39, 39, 39);

  ThemeMode _themeMode = ThemeMode.system;

  void _handleThemeChange(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: lightmodeTextColor),
          backgroundColor: lightmodeBackgroundColor,
          titleTextStyle: TextStyle(color: lightmodeTextColor),
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(color: lightmodeTextColor, fontWeight: FontWeight.bold),
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
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(color: darkmodeTextColor, fontWeight: FontWeight.bold),
        ),
        scaffoldBackgroundColor: darkmodeBackgroundColor,
        textTheme: TextTheme(bodyMedium: TextStyle(color: darkmodeTextColor)),
      ),
      themeMode: _themeMode,
      home: MenuPage(onThemeChanged: _handleThemeChange),
    );
  }
}
