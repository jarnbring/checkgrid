import 'package:checkgrid/new_game/utilities/piecetype.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GeneralProvider with ChangeNotifier {
  double _bannerAdHeight = 90.0;
  double fontSizeInAppbar = 20.0;
  final double pieceInSelectorSize = 75.0;

  // General constants
  final double iconSize = 50.0;
  static final int boardHeight = 8; // Minimum 8
  static final int boardWidth = 10; // Minimum 8

  // Game constants
  final int comboRequirement = 6;

  // Ad constants
  final int countdownTime = 5;

  // ---------- METHODS ----------

  Widget pieceImage(
    double? size,
    PieceType pieceType,
    BoxFit? boxFit,
    BuildContext context,
  ) {
    final isDarkPieces = context.watch<SettingsProvider>().isDarkPieces;
    return Image.asset(
      isDarkPieces
          ? 'assets/images/pieces/black/black_${pieceType.name}.png'
          : 'assets/images/pieces/white/white_${pieceType.name}.png',
      width: size,
      height: size,
      fit: boxFit,
    );
  }

  // ---------- STORE ----------

  String getUserCurrencyCode(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // Mappa landskod till valutakod (enkel mappning, utöka vid behov)
    final currencyMap = {
      'US': 'USD',
      'GB': 'GBP',
      'SE': 'SEK',
      'EU': 'EUR',
      // Lägg till fler
    };
    return currencyMap[locale.countryCode] ?? 'USD'; // Fallback till USD
  }

  String formatPrice(double price, String currencyCode) {
    final formatter = NumberFormat.currency(locale: currencyCode, symbol: '');
    return formatter.format(price);
  }

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
}
