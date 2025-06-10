import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:checkgrid/ads/reward_ad.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownLoading extends StatefulWidget {
  final VoidCallback onRestart;
  final VoidCallback afterAd;
  final bool isReviveShowing;

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
  bool hasRevived = false;
  final RewardedAdService _rewardedAdService = RewardedAdService();
  bool isAdBeingShown = false;
  late int amountOfRoundsPlayed;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    hasRevived = false;
    isAdBeingShown = false;
    _rewardedAdService.loadAd();
    _initPrefsAndStartTimer();
  }

  Future<void> _initPrefsAndStartTimer() async {
    prefs = await SharedPreferences.getInstance();
    _loadRoundsPlayed();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter == 0) {
        timer.cancel();
        _saveRoundsPlayed();
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

  void _loadRoundsPlayed() {
    String? roundsPlayed = prefs.getString('rounds_played');
    amountOfRoundsPlayed = roundsPlayed != null ? int.parse(roundsPlayed) : 0;
  }

  void _saveRoundsPlayed() {
    amountOfRoundsPlayed++;
    prefs.setString('rounds_played', amountOfRoundsPlayed.toString());
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(153, 0, 0, 0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                GestureDetector(
                  onTap: () {
                    isAdBeingShown = true;
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
                        setState(() {});
                      },
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 40, 188, 45),
                      borderRadius: BorderRadius.circular(15),
                    ),
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
        ),
      ),
    );
  }
}
