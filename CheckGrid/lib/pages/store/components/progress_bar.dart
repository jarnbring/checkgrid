import 'package:flutter/material.dart';

class AdProgressBar extends StatelessWidget {
  final int rewardedAdsWatched;
  final int adsRequired;

  const AdProgressBar({
    super.key,
    required this.rewardedAdsWatched,
    required this.adsRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Watch ads to unlock special skin:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: rewardedAdsWatched / adsRequired,
          minHeight: 12,
          backgroundColor: Colors.grey.shade300,
          color: Colors.orange,
        ),
        const SizedBox(height: 4),
        Text(
          "$rewardedAdsWatched / $adsRequired ads watched",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
