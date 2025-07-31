import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/game/board.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Score extends StatefulWidget {
  const Score({super.key});

  @override
  State<Score> createState() => _ScoreState();
}

class _ScoreState extends State<Score> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  BigInt _lastHighScore = BigInt.zero;
  bool _isHighScore = false;
  bool _hasCheckedInitial = false; // För att undvika flera kontroller

  @override
  void initState() {
    super.initState();

    // Pulse animation - snabb puls
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Glow animation - långsam lysning
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Kontrollera highscore-status när widgeten initialiseras
    // Prova både postFrameCallback OCH direkt i didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialHighScore();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Backup: Kolla även här ifall postFrameCallback inte fungerar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialHighScore();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _checkForHighScore(Board board) {
    // Kontrollera om highscore-status har förändrats
    final shouldBeHighScore =
        (board.currentScore == board.highScore &&
            board.currentScore > BigInt.zero) ||
        board.isAnimatingHighScore;

    if (shouldBeHighScore && !_isHighScore) {
      setState(() {
        _isHighScore = true;
      });
      _startHighScoreAnimation();
    } else if (!shouldBeHighScore && _isHighScore) {
      setState(() {
        _isHighScore = false;
      });
      _stopHighScoreAnimation();
    }
  }

  void _checkInitialHighScore() {
    // Undvik att köra flera gånger
    if (_hasCheckedInitial) return;
    _hasCheckedInitial = true;

    final board = context.read<Board>();

    // Debug: Skriv ut värdena för att se vad som händer
    print(
      'Initial check - currentScore: ${board.currentScore}, highScore: ${board.highScore}',
    );

    // Kontrollera om spelaren redan har ett aktivt highscore när appen startar
    // Om currentScore == highScore och båda är > 0, då var spelaren mitt i en highscore-runda
    if (board.currentScore == board.highScore &&
        board.currentScore > BigInt.zero &&
        board.highScore > BigInt.zero) {
      print('Starting highscore animation on app load!');

      setState(() {
        _isHighScore = true;
      });
      _startHighScoreAnimation();
    } else {
      print('No initial highscore animation needed');
    }
  }

  void _startHighScoreAnimation() {
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  void _stopHighScoreAnimation() {
    _pulseController.stop();
    _glowController.stop();
    _pulseController.reset();
    _glowController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final board = context.watch<Board>();

    // Kontrollera highscore-status
    _checkForHighScore(board);

    final scoreText =
        board.currentScore >= BigInt.from(9223372036854775807)
            ? "MAX"
            : NumberFormat("#,###").format(board.currentScore.toInt());

    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = _calculateFontSize(scoreText, constraints.maxWidth);

        Widget scoreWidget = OutlinedText(text: scoreText, fontSize: fontSize);

        // Om det är highscore, lägg till animationer
        if (_isHighScore) {
          return AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _glowController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      // Gul glöd-effekt
                      BoxShadow(
                        color: Colors.yellow.withOpacity(
                          _glowAnimation.value * 0.8,
                        ),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 10 * _glowAnimation.value,
                      ),
                      // Gul inre glöd
                      BoxShadow(
                        color: Colors.amber.withOpacity(
                          _glowAnimation.value * 0.6,
                        ),
                        blurRadius: 10 * _glowAnimation.value,
                        spreadRadius: 7 * _glowAnimation.value,
                      ),
                      // Vit kärna för extra lyskraft
                      BoxShadow(
                        color: Colors.white.withOpacity(
                          _glowAnimation.value * 0.4,
                        ),
                        blurRadius: 5 * _glowAnimation.value,
                        spreadRadius: 5 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [
                            Colors.yellow,
                            Colors.amber,
                            Colors.orange,
                            Colors.yellow,
                          ],
                          stops: [
                            0.0,
                            _glowAnimation.value * 0.3,
                            _glowAnimation.value * 0.7,
                            1.0,
                          ],
                        ).createShader(bounds),
                    child: scoreWidget,
                  ),
                ),
              );
            },
          );
        }

        return scoreWidget;
      },
    );
  }

  double _calculateFontSize(String text, double availableWidth) {
    double estimatedCharWidth = 20;
    double estimatedTextWidth = text.length * estimatedCharWidth;
    if (estimatedTextWidth <= availableWidth) {
      return 32;
    }
    double scale = availableWidth / estimatedTextWidth;
    return (32 * scale).clamp(16, 32);
  }
}

class GameAnimations {
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

  // Ny funktion för highscore-animering som behåller guldigt utseende
  static Future<void> increaseHighScore(
    BigInt oldScore,
    BigInt newScore,
    void Function(BigInt, bool) onUpdate, {
    int durationMs = 500,
    int steps = 10,
  }) async {
    final diff = newScore - oldScore;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: durationMs ~/ steps));
      // Andra parametern (true) indikerar att det är highscore-animering
      onUpdate(oldScore + (diff * BigInt.from(i) ~/ BigInt.from(steps)), true);
    }
  }
}
