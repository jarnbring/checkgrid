import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gamename/ads/reward_ad.dart';

class CountdownLoading extends StatefulWidget {
  final VoidCallback onRestart; // Callback för att anropa restartGame
  final VoidCallback afterAd;
  final bool isReviveShowing; // Kontrollera om revive-dialogen ska visas

  const CountdownLoading({
    super.key,
    required this.onRestart,
    required this.afterAd,
    required this.isReviveShowing,
  });

  @override
  State<CountdownLoading> createState() => _CountdownLoadingState();
}

class _CountdownLoadingState extends State<CountdownLoading> {
  int _counter = 5;
  late Timer _timer;
  bool _isDialogOpen = false;
  bool hasRevived = false; // NY FLAGGA
  RewardedAdService _rewardedAdService = RewardedAdService();
  bool isAdBeingShown = false; // NY

  @override
  void initState() {
    super.initState();

    hasRevived = false; // Lägg till detta
    isAdBeingShown = false; // Och detta

    _rewardedAdService.loadAd();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter == 0) {
        timer.cancel();
        if (!hasRevived && !isAdBeingShown && mounted) {
          widget.onRestart();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      } else {
        setState(() {
          _counter--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(153, 0, 0, 0),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            Stack(
              alignment: Alignment.center,
              children: [
                const SpinKitDoubleBounce(color: Colors.blue, size: 250.0),
                Text(
                  '$_counter',
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Container(
              width: 200,
              height: 55,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 40, 188, 45),
                borderRadius: BorderRadius.circular(15),
              ),
              child: GestureDetector(
                onTap: () {
                  isAdBeingShown =
                      true; // STOPPA timern från att trigga restartGame

                  _rewardedAdService.showAd(
                    onUserEarnedReward: () {
                      hasRevived = true;
                      widget.afterAd();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    onAdDismissed: () {
                      if (!hasRevived) {
                        widget.onRestart();
                      }
                      setState(() {
                        _isDialogOpen = false;
                      });
                    },
                  );
                },
                child: const Center(
                  child: Text(
                    "Revive?",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
