import 'package:checkgrid/ads/banner_ad.dart';
import 'package:checkgrid/new_game/dialogs/settings_dialog.dart';
import 'package:checkgrid/new_game/game_board.dart';
import 'package:checkgrid/new_game/utilities/background.dart';
import 'package:checkgrid/new_game/utilities/score.dart';
import 'package:checkgrid/new_game/board.dart';
import 'package:checkgrid/new_game/piece_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Handle UI on the gamescreen

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final Board board = Board();
  BigInt currentScore = BigInt.zero;

  @override
  void initState() {
    super.initState();
    board.prepareNewBoard();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: board,
      child: Stack(
        children: [
          Background(
            child: Scaffold(
              backgroundColor: Colors.transparent, // Viktigt!
              appBar: AppBar(
                backgroundColor: Colors.transparent, // Viktigt!
                elevation: 0,
                foregroundColor: Colors.transparent,
                centerTitle: true,
                title: const Text("CheckGrid", style: TextStyle(fontSize: 26)),
                // Back button
                leading: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // Save game
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/menu');
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                // Settings button
                actions: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        showSettingsDialog(
                          context: context,
                          onRestart: board.restartGame,
                          onSettingsPage: () {
                            context
                                .pushNamed("/settings")
                                .then((_) => board.update());
                          },
                          currentDifficulty: board.difficulty,
                          onDifficultySelected: (newDifficulty) {
                            setState(() {
                              board.difficulty = newDifficulty;
                              board.restartGame();
                            });
                          },
                        );
                      },
                      child: const Icon(Icons.settings),
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Consumer<Board>(builder: (context, board, _) => Score()),
                    const SizedBox(height: 30),
                    Consumer<Board>(
                      builder: (context, board, _) => GameBoard(),
                    ),
                    const SizedBox(height: 30),
                    Consumer<Board>(
                      builder: (context, board, _) => PieceSelector(),
                    ),
                    const SizedBox(height: 30),
                    _buildReviveButton() ?? const SizedBox(),
                    _buildGameOverButton() ?? const SizedBox(),
                  ],
                ),
              ),
              bottomNavigationBar: const BannerAdWidget(),
            ),
          ),
        ],
      ),
    );
  }

  // For debug
  Widget? _buildReviveButton() {
    if (kDebugMode) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 36,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {
              board.debugSetRevive(context);
            },
            child: const Text(
              'Revive',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      );
    }
    return null;
  }

  Widget? _buildGameOverButton() {
    if (kDebugMode) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 36,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {
              board.debugSetGameOver();
            },
            child: const Text(
              'Game Over',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      );
    }
    return null;
  }
}
