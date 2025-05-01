import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GeneralProvider with ChangeNotifier {
  double _bannerAdHeight = 90.0;
  double fontSizeInAppbar = 20.0;

  get fontSize => 20.0; 

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

  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  bool getLandscapeMode(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.shortestSide >= 600;
}

  double getBannerAdHeight() {
    return _bannerAdHeight;
  }

  void setBannerAdHeight(double height) {
    _bannerAdHeight = height;
    notifyListeners();
  }
}