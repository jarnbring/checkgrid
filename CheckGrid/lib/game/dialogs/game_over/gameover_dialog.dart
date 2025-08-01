import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/components/background.dart';
import 'package:checkgrid/providers/audio_provider.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GameOverPage extends StatefulWidget {
  final Board board;
  const GameOverPage({super.key, required this.board});

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  bool isPressedRestart = false;
  bool isPressedMenu = false;

  @override
  void initState() {
    super.initState();
    context.read<AudioProvider>().playGameOver();
    widget.board.updateAmountOfRounds(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Background(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedText(
                  text: "Game Over",
                  fontSize: 60,
                  color: Color.fromARGB(255, 174, 174, 174),
                  textAlign: TextAlign.center,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(3, 3),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(3, 3),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(3, 3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 100),
                _button(
                  "Restart",
                  () {
                    context.read<SettingsProvider>().doVibration(1);
                    widget.board.restartGame(context, false);
                    context.go('/home');
                  },
                  isPressedRestart,
                  (v) => setState(() => isPressedRestart = v),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
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
}
