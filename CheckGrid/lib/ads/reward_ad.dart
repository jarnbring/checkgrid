import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  final VoidCallback onRewardEarned;
  final VoidCallback onAdDismissed;

  final String adUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917' // Test ID för Android
          : 'ca-app-pub-3940256099942544/1712485313'; // Test ID för iOS

  RewardedAdManager({
    required this.onRewardEarned,
    required this.onAdDismissed,
  }) {
    _loadAd();
  }

  void _loadAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAd() {
    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          onAdDismissed();
          ad.dispose();
          _loadAd(); // Ladda en ny annons efteråt
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Ad failed to show: $error');
          ad.dispose();
          _loadAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );

      _rewardedAd = null;
      _isAdLoaded = false;
    } else {
      debugPrint('Ad is not ready');
    }
  }
}

class RewardedAdService {
  RewardedAd? _rewardedAd;

  final String adUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917' // Android
          : 'ca-app-pub-3940256099942544/1712485313'; // IOS

  bool get isLoaded => _rewardedAd != null;

  Future<void> loadAd() async {
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void showAd({
    required VoidCallback onUserEarnedReward,
    required VoidCallback onAdDismissed,
    required BuildContext context,
  }) {
    if (isLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onAdDismissed();
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Ad failed to show: $error');
          ad.dispose();
          onAdDismissed();
          loadAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward();
        },
      );

      _rewardedAd = null;
    } else {
      debugPrint("RewardedAd not ready yet");
    }
  }
}
