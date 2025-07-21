import 'dart:async';

import 'package:checkgrid/components/error_dialog.dart';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/providers/ad_provider.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _loadingDone = false;
  bool _boardLoaded = false;
  bool _isFirstTimeUser = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleAnimationCompleted();
      }
    });
  }

  void _handleAnimationCompleted() {
    if (_loadingDone && mounted) {
      // Loading är klart, navigera nu
      _navigateToNextScreen();
    } else {
      // Loading inte klart än, upprepa animationen
      _lottieController.forward(from: 0);
    }
  }

  void _navigateToNextScreen() {
    _fadeController.forward().then((_) async {
      if (!mounted) return;
      if (_isFirstTimeUser) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('first_time', false);
        if (!mounted) return;
        context.go('/tutorial');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_boardLoaded) {
      _boardLoaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final board = context.read<Board>();
    _isFirstTimeUser = await GeneralProvider.isFirstTime();

    if (!_isFirstTimeUser) {
      bool shouldAskAgain = true;

      while (shouldAskAgain) {
        try {
          if (!mounted) return;
          await board
              .loadBoard(context)
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () => throw TimeoutException('Load board timed out'),
              );
          shouldAskAgain = false;
        } on TimeoutException {
          if (!mounted) return;

          final createNew = await showDialog<bool>(
            context: context,
            builder: (context) => const ErrorDialog(),
          );

          // User wanted to create a new board
          if (createNew == true) {
            board.createNewBoard();
            shouldAskAgain = false;
          }

          // User did not want to create a new board, keep looping
        }
      }
    } else {
      board.createNewBoard();
    }

    // Prepare the store
    if (!mounted) return;
    await context.read<SkinProvider>().initialize();

    // Prepare the first video ad
    if (!mounted) return;
    final adToShow =
        Provider.of<AdProvider>(context, listen: false).rewardedAdService;
    await adToShow.loadAd();

    _loadingDone = true;

    // Om animationen redan är klar, navigera direkt
    if (_lottieController.status == AnimationStatus.completed) {
      _navigateToNextScreen();
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 200),
            FadeTransition(
              opacity: ReverseAnimation(_fadeAnimation),
              child: Lottie.asset(
                'assets/images/animations/loading.json',
                controller: _lottieController,
                frameRate: FrameRate.max,
                onLoaded: (composition) {
                  _lottieController.duration = composition.duration;
                  _lottieController.forward();
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
