import 'dart:async';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/providers/ad_provider.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:checkgrid/ads/reward_ad.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CountdownLoading extends StatefulWidget {
  final VoidCallback afterAd;
  final Board board;

  const CountdownLoading({
    super.key,
    required this.afterAd,
    required this.board,
  });

  @override
  State<CountdownLoading> createState() => _CountdownLoadingState();
}

class _CountdownLoadingState extends State<CountdownLoading> {
  // Ad
  late RewardedAdService adToShow;

  // Time
  late int _counter;
  Timer? _timer;

  // Bools to keep track of what's showing at the moment
  bool isRevived = false;
  bool isAdBeingShown = false;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _timer
        ?.cancel(); // Good habit to dispose this, otherwise it will be in the background after the ad
    super.dispose();
  }

  /// Loads the ad and starts the countdown timer.
  Future<void> _initialize() async {
    // Load providers
    final generalProvider = Provider.of<GeneralProvider>(
      context,
      listen: false,
    );
    final adProvider = Provider.of<AdProvider>(context, listen: false);

    // Set and start the timer
    _counter = generalProvider.countdownTime;
    _startCountdown();

    // Get the ad ready
    adToShow = adProvider.rewardedAdService;
  }

  /// Starts the countdown timer.
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter == 0) {
        timer.cancel();
        _onCountdownFinished();
      } else {
        setState(() {
          _counter--;
        });
      }
    });
  }

  /// Handles what happens when the countdown reaches zero.
  void _onCountdownFinished() {
    // The user did not watch the ad
    if (isRevived) return;
    if (isAdBeingShown) return;
    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    context.go('/gameover', extra: widget.board);
  }

  // Handles the revive action via rewarded ad.
  void _onRevivePressed() {
    // These are necessary to avoid bugs, ex spam-clicking "Revive?"
    if (isAdBeingShown) return;
    if (isRevived) return;
    if (!adToShow.isLoaded) return;

    isAdBeingShown = true;

    adToShow.showAd(
      onUserEarnedReward: () {
        isRevived = true;
        widget.afterAd();
        widget.board.saveBoard(context);
        Navigator.pop(context);
      },
      onAdDismissed: () {
        if (isRevived) return;

        context.go('/gameover', extra: widget.board);

        setState(() {
          isAdBeingShown = false;
        });
      },
    );
    adToShow.loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(107, 0, 0, 0),
      body: Center(
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
                  const SpinKitCircle(
                    color: CupertinoColors.systemBlue,
                    size: 250.0,
                  ),
                  Text(
                    '$_counter',
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              StatefulBuilder(
                builder: (context, setLocalState) {
                  return GestureDetector(
                    onTap: () {
                      context.read<SettingsProvider>().doVibration(1);

                      if (isAdBeingShown) return;
                      _onRevivePressed();
                    },
                    onTapDown: (_) => setState(() => isPressed = true),
                    onTapUp: (_) => setState(() => isPressed = false),
                    onTapCancel: () => setState(() => isPressed = false),
                    child: AnimatedScale(
                      scale: isPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        width: 200,
                        height: 55,
                        decoration: BoxDecoration(
                          color:
                              isPressed
                                  ? const Color.fromARGB(255, 30, 140, 35)
                                  : const Color.fromARGB(255, 40, 188, 45),
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
