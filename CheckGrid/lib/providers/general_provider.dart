import 'package:checkgrid/game/utilities/piecetype.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralProvider with ChangeNotifier {
  double _bannerAdHeight = 90.0;
  double fontSizeInAppbar = 20.0;
  final double pieceInSelectorSize = 75.0;
  final double dialogWidth = 300;
  final double dialogHeight = 450;

  // General constants
  final double iconSize = 50.0;
  static final int boardHeight = 8; // Default 8
  static final int boardWidth = 8; // Default 8

  // Game constants
  final int comboRequirement = 6;

  // Ad constants
  final int countdownTime = 5;

  // User constants
  static bool isFirstTimeUser = false;

  // ---------- METHODS ----------

  Widget pieceImage(
    double? size,
    PieceType pieceType,
    BoxFit? boxFit,
    BuildContext context,
  ) {
    final skinName = context.watch<SkinProvider>().selectedSkin.name;
    return Padding(
      padding: EdgeInsetsGeometry.all(8),
      child: Image.asset(
        'assets/images/pieces/$skinName/${skinName}_${pieceType.name}.png',
        width: size,
        height: size,
        fit: boxFit,
      ),
    );
  }

  // ---------- STORE ----------

  // Currency / format

  // ---------- ADS ----------

  double getBannerAdHeight() {
    return _bannerAdHeight;
  }

  void setBannerAdHeight(double height) {
    _bannerAdHeight = height;
    notifyListeners();
  }

  // ---------- DEVICE ----------

  double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  // ---------- USER ----------

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getBool('first_time') ?? true;

    isFirstTimeUser = firstTime;
    return firstTime;
  }
}
