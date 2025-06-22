import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';

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
  bool _shouldRepeat = true;

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
        if (_loadingDone && mounted) {
          // Starta fade ut direkt
          _fadeController.forward().then((_) {
            if (mounted) context.go('/menu');
          });
        } else if (_shouldRepeat) {
          _lottieController.forward(from: 0);
        }
      }
    });
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulerad laddning
    _loadingDone = true;
    _shouldRepeat = false;
    // Om Lottie redan är klar, starta fade direkt
    if (_lottieController.status == AnimationStatus.completed && mounted) {
      _fadeController.forward().then((_) {
        if (mounted) context.go('/menu');
      });
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
        child: FadeTransition(
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
      ),
    );
  }
}
