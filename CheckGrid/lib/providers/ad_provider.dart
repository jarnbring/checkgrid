import 'package:checkgrid/ads/reward_ad.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdProvider with ChangeNotifier {
  final RewardedAdService _rewardedAdService = RewardedAdService();

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  bool isRewardedAdLoaded = false;

  AdProvider() {
    loadBannerAd();
    loadRewardedAd();
  }

  void loadRewardedAd() {
    _rewardedAdService.loadAd();
  }

  void loadBannerAd() async {
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          320, // exempel bredd, du kan ta från MediaQuery i widget också
        );

    if (adSize == null) return;

    _bannerAd?.dispose();

    _bannerAd = BannerAd(
      adUnitId:
          Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/9214589741' // Android test id
              : 'ca-app-pub-3940256099942544/2435281174', // iOS test id
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerAdLoaded = false;
          notifyListeners();
          // Kan försöka ladda igen efter delay
          Future.delayed(const Duration(seconds: 5), () => loadBannerAd());
        },
      ),
    );

    await _bannerAd!.load();
  }

  void showRewardedAd({
    required VoidCallback onReward,
    required VoidCallback onDismissed,
  }) {
    if (!isRewardedAdLoaded) return;
    _rewardedAdService.showAd(
      onUserEarnedReward: onReward,
      onAdDismissed: onDismissed,
    );
    isRewardedAdLoaded = false;
    notifyListeners();
    loadRewardedAd();
  }

  // Getters
  RewardedAdService get rewardedAdService => _rewardedAdService;
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  void disposeBanner() {
    _bannerAd?.dispose();
  }
}
