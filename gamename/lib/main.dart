import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gamename/pages/menu_page.dart';
import 'package:gamename/provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder:
          (context) => ChangeNotifierProvider(
            create: (_) => SettingsProvider(),
            child: const MyApp(),
          ),
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
  final Color darkmodeTextColor = Colors.white;
  final Color lightmodeBackgroundColor = Colors.white;
  final Color lightmodeTextColor = const Color.fromARGB(255, 39, 39, 39);

  @override
  void initState() {
    super.initState();

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
          titleTextStyle: TextStyle(
            color: lightmodeTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: lightmodeBackgroundColor,
        iconTheme: IconThemeData(
          color: darkmodeBackgroundColor
        ),
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
          titleTextStyle: TextStyle(color: darkmodeTextColor),
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(
            color: darkmodeTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: darkmodeBackgroundColor,
        cardColor: darkmodeTextColor,
        iconTheme: IconThemeData(
          color: lightmodeBackgroundColor
        ),
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
      home: MenuPage(),
    );
  }
}
