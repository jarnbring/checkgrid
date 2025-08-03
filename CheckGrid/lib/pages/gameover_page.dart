import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/components/background.dart';
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
  late Animation<Offset> _textOffset;
  late Animation<double> _textOpacity;
  late Animation<Offset> _buttonOffset;
  late Animation<double> _buttonOpacity;
  late Animation<double> _pulse;

  late final String lastScore;

  @override
  void initState() {
    super.initState();
    context.read<AudioProvider>().playGameOver();
    widget.board.updateAmountOfRounds(context);
    lastScore = widget.board.lastScore.toString();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _button(
    String title,
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
                isPressed ? const Color(0xFF1976D2) : const Color(0xFF4FC3F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Background(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 80.0,
              vertical: 200,
            ),
            child: Column(
              children: [
                SlideTransition(
                  position: _textOffset,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: OutlinedText(
                      text: "Game Over",
                      fontSize: 45,
                      color: const Color.fromARGB(255, 174, 174, 174),
                      textAlign: TextAlign.center,
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
                const SizedBox(height: 100),
                SlideTransition(
                  position: _textOffset,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: OutlinedText(text: lastScore, fontSize: 45),
                  ),
                ),
                const SizedBox(height: 100),
                SlideTransition(
                  position: _buttonOffset,
                  child: FadeTransition(
                    opacity: _buttonOpacity,
                    child: ScaleTransition(
                      scale: _pulse,
                      child: _button(
                        "Restart",
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
    );
  }
}
