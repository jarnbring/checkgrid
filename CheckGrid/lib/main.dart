import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/utilities/cell.dart';
import 'package:checkgrid/game/utilities/piecetype.dart';
import 'package:checkgrid/providers/ad_provider.dart';
import 'package:checkgrid/providers/board_provider.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:checkgrid/providers/router.dart';
import 'package:checkgrid/settings/noti_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure MobileAds
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['EMULATOR']),
  );
  await MobileAds.instance.initialize();

  // Configure Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CellAdapter());
  Hive.registerAdapter(PieceTypeAdapter());

  // Load Hive
  final boardProvider = BoardProvider();
  await boardProvider.initFuture;

  // Load settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Init NotificationService
  final notiService = NotiService();

  await notiService.initNotification();

  // Schedule daily notifications
  //await notiService.scheduleWeeklyRotatingNotifications(settingsProvider);

  runApp(
    MultiProvider(
      providers: [
        // Initialize providers
        ChangeNotifierProvider.value(value: boardProvider),
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => Board()),
        ChangeNotifierProvider(create: (_) => SkinProvider()),

        // Use value to avoid re-creating the provider
        ChangeNotifierProvider.value(value: settingsProvider),
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Darkmode colors
  final Color darkmodeBackgroundColor = const Color.fromARGB(255, 39, 39, 39);
  final Color darkmodeTextColor = Colors.white;

  // Lightmode colors
  final Color lightmodeBackgroundColor = Colors.white;
  final Color lightmodeTextColor = const Color.fromARGB(255, 39, 39, 39);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOrientations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // debugPrint("SAVING BOARD...");
      // final stopwatch = Stopwatch()..start();
      // board.saveBoard(context);
      // stopwatch.stop();
      // print('Sparande tog ${stopwatch.elapsedMilliseconds} ms');
    }
  }

  void _setOrientations() {
    // Set orientations to be allowed, can be changed later depending on tablet
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CheckGrid',
      routerConfig: router,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: lightmodeTextColor),
          backgroundColor: Colors.transparent,
          //backgroundColor: lightmodeBackgroundColor,
          titleTextStyle: GoogleFonts.poppins(
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
          titleTextStyle: GoogleFonts.poppins(
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
          bodyMedium: GoogleFonts.poppins(
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
          titleTextStyle: GoogleFonts.poppins(
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
          titleTextStyle: GoogleFonts.poppins(
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
          bodyMedium: GoogleFonts.poppins(
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
