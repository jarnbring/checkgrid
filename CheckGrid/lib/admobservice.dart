import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  // RIKTIGT APP-ID: ca-app-pub-5847580416712446~5852422435

  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5847580416712446~5852422435'; // Test Banner ID för Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test Banner ID för iOS
    }
    return null;
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial ID för Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test Interstitial ID för iOS
    }
    return null;
  }

  static String? get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded ID för Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test Rewarded ID för iOS
    }
    return null;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Banner-annons laddad'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Banner-annons misslyckades: $error');
    },
    onAdOpened: (ad) => debugPrint('Banner öppnad'),
    onAdClosed: (ad) => debugPrint('Banner stängd'),
  );
}
