import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/components/background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: Background(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Game\n Over",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF81D4FA),
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                _button(
                  "Restart",
                  () {
                    widget.board.restartGame();
                    context.go('/play');
                  },
                  isPressedRestart,
                  (v) => setState(() => isPressedRestart = v),
                ),
                const SizedBox(height: 24),
                _button(
                  "Back to Menu",
                  () {
                    context.go('/menu');
                  },
                  isPressedMenu,
                  (v) => setState(() => isPressedMenu = v),
                ),
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
