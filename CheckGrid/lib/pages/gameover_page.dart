import 'package:checkgrid/components/app_scaler.dart';
import 'package:checkgrid/game/utilities/score.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/providers/audio_provider.dart';
import 'package:checkgrid/providers/settings_provider.dart';

class GameOverPage extends StatefulWidget {
  final Board board;
  const GameOverPage({super.key, required this.board});

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage>
    with TickerProviderStateMixin {
  bool isPressedRestart = false;
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<Offset> _textOffset;
  late Animation<double> _textOpacity;
  late Animation<Offset> _buttonOffset;
  late Animation<double> _buttonOpacity;
  late Animation<double> _pulse;
  late Animation<double> _bounce;

  late final BigInt finalScore;
  BigInt currentScore = BigInt.zero; // Håller nuvarande animerade score

  @override
  void initState() {
    super.initState();
    context.read<AudioProvider>().playGameOver();
    widget.board.updateAmountOfRounds(context);
    finalScore = widget.board.lastScore;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOffset = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _buttonOffset = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _pulse = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounce = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutBack),
    );

    // Starta fade/slide animationen först
    _controller.forward();

    // Starta score-animationen efter att fade transition är klar
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          _startScoreAnimation();
        }
      }
    });
  }

  Future<void> _startScoreAnimation() async {
    // Använd GameAnimations.animateScore för att animera från 0 till finalScore
    await GameAnimations.animateScore(
      BigInt.zero,
      finalScore,
      (v, [isHighScore]) {
        if (mounted) {
          setState(() {
            currentScore = v;
          });
        }
      },
      steps: 100,
      durationMs: 2500,
    );

    // När score-animationen är klar, starta bounce-animationen
    if (mounted) {
      await _bounceController.forward();
      if (mounted) {
        await _bounceController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Widget _button(
    VoidCallback onTap,
    bool isPressed,
    void Function(bool) setPressed,
  ) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => setPressed(true),
      onTapUp: (_) => setPressed(false),
      onTapCancel: () => setPressed(false),
      child: AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:
                isPressed
                    ? const Color.fromARGB(255, 35, 160, 39)
                    : const Color.fromARGB(255, 45, 190, 49),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(FontAwesomeIcons.arrowsRotate, size: 24),
        ),
      ),
    );
  }

  RadialGradient gameOverGradient() {
    return RadialGradient(
      center: Alignment(0.0, -0.3),
      radius: 1.2,
      colors: [
        Color(0xFF90C8FF), // mjuk ljusblå
        Color(0xFF3A8DFF), // klar blå
        Color(0xFF1E4FA1), // djup blå
        Color.fromARGB(255, 24, 50, 101), // nästan svartblå
      ],
      stops: [0.0, 0.35, 0.7, 1.0],
    );
  }

  RadialGradient newHighScoreGradient() {
    return RadialGradient(
      center: Alignment(0.0, -0.3),
      radius: 1.2,
      colors: [
        Color(0xFFFFF59D), // ljus gul
        Color(0xFFFFC107), // varm guld
        Color(0xFFFF4081), // klar magenta/rosa
        Color(0xFF7C4DFF), // lila
      ],
      stops: [0.0, 0.35, 0.55, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaler(
      gradient:
          widget.board.isHighScore
              ? newHighScoreGradient()
              : gameOverGradient(),
      useCustomBackground: true,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient:
                widget.board.isHighScore
                    ? newHighScoreGradient()
                    : gameOverGradient(),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 48.0,
                vertical: 160,
              ),
              child: Column(
                children: [
                  SlideTransition(
                    position: _textOffset,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child:
                          widget.board.isHighScore
                              ? OutlinedText(
                                text: "New Highscore!",
                                fontSize: 34,
                                color: const Color.fromARGB(255, 240, 240, 238),
                                textAlign: TextAlign.center,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(3, 3),
                                    blurRadius: 10,
                                  ),
                                ],
                              )
                              : Text(
                                "Game Over",
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 86, 96, 102),
                                ),
                                textAlign: TextAlign.center,
                              ),
                    ),
                  ),

                  const SizedBox(height: 80),
                  SlideTransition(
                    position: _textOffset,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: ScaleTransition(
                        scale: _bounce,
                        child: OutlinedText(
                          fontSize: 36,
                          text: NumberFormat(
                            '#,###',
                          ).format(currentScore.toInt()),
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(3, 3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SlideTransition(
                    position: _buttonOffset,
                    child: FadeTransition(
                      opacity: _buttonOpacity,
                      child: ScaleTransition(
                        scale: _pulse,
                        child: _button(
                          () {
                            context.read<AudioProvider>().playOpenMenu();
                            context.read<SettingsProvider>().doVibration(1);
                            widget.board.restartGame(context, false);
                            context.go('/home');
                          },
                          isPressedRestart,
                          (v) => setState(() => isPressedRestart = v),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
