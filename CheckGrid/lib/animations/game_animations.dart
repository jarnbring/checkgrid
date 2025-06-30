import 'package:flutter/material.dart';

class GameAnimations {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _glossAnimationController;
  late Animation<double> _glossAnimation;

  GameAnimations(TickerProvider vsync) {
    // Initialize fade animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: vsync,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    // Initialize gloss animation
    _glossAnimationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: vsync,
    );
    _glossAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _glossAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _glossAnimationController.repeat(reverse: true);
  }

  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<double> get glossAnimation => _glossAnimation;

  AnimationController get animationController => _animationController;
  AnimationController get glossAnimationController => _glossAnimationController;

  void dispose() {
    _animationController.dispose();
    _glossAnimationController.dispose();
  }

  // Utility function to animate BigInt values (e.g., for score and high score)
  Future<void> animateBigInt(
    BigInt start,
    BigInt end,
    void Function(BigInt) onUpdate,
  ) async {
    const durationMs = 500;
    const steps = 20;
    final diff = end - start;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: durationMs ~/ steps));
      onUpdate(start + (diff * BigInt.from(i) ~/ BigInt.from(steps)));
    }
  }

  static Future<void> increaseScore(
    BigInt oldScore,
    BigInt newScore,
    void Function(BigInt) onUpdate, {
    int durationMs = 500,
    int steps = 10,
  }) async {
    final diff = newScore - oldScore;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: durationMs ~/ steps));
      onUpdate(oldScore + (diff * BigInt.from(i) ~/ BigInt.from(steps)));
    }
  }
}
