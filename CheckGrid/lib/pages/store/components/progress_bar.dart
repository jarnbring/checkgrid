import 'package:flutter/cupertino.dart';
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
    final double progress = rewardedAdsWatched / adsRequired;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Watch ads to unlock special skin:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                CupertinoColors.systemGreen,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$rewardedAdsWatched / $adsRequired",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
