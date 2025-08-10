import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing rewarded ads.
///
/// Handles loading, showing, and disposing of rewarded ads with proper
/// state management and error handling.
class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  final String adUnitId =
      Platform.isAndroid
          ? (kDebugMode
              ? 'ca-app-pub-3940256099942544/5224354917' // Test ID for Android
              : 'YOUR_REAL_ANDROID_ID') // Replace with real ID
          : (kDebugMode
              ? 'ca-app-pub-3940256099942544/1712485313' // Test ID for iOS
              : 'YOUR_REAL_IOS_ID'); // Replace with real ID

  bool get isLoaded => _rewardedAd != null && !_isLoading;
  bool get isLoading => _isLoading;

  Future<void> loadAd() async {
    // Don't load if already loading or loaded
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  Future<void> showAd({
    required VoidCallback onUserEarnedReward,
    required VoidCallback onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) async {
    // Ad is not ready
    if (!isLoaded) {
      onAdFailedToShow?.call();
      return;
    }

    // Set up callbacks before showing
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null; // Clear after disposal
        onAdDismissed();
        loadAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null; // Clear after disposal
        if (onAdFailedToShow != null) {
          onAdFailedToShow();
        } else {
          onAdDismissed();
        }
        loadAd(); // Preload next ad
      },
    );

    // Show the ad
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward();
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoading = false;
  }
}
