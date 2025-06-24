import 'package:checkgrid/ads/reward_ad.dart';
import 'package:flutter/material.dart';

class AdProvider with ChangeNotifier {
  final RewardedAdService _rewardedAdService = RewardedAdService();
  bool isRewardedAdLoaded = false;

  AdProvider() {
    loadRewardedAd();
  }

  void loadRewardedAd() {
    _rewardedAdService.loadAd();
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
    loadRewardedAd(); // Ladda nästa direkt
  }

  // Getter
  RewardedAdService get rewardedAdService => _rewardedAdService;
}
