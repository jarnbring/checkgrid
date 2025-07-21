// ignore_for_file: unused_element

import 'package:checkgrid/game/dialogs/settings/settings_dialog.dart';
import 'package:checkgrid/game/game_board.dart';
import 'package:checkgrid/game/utilities/score.dart';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/piece_selector.dart';
import 'package:checkgrid/providers/audio_provider.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/settings_provider.dart';
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
  late final Board board;

  @override
  void initState() {
    super.initState();
    board = context.read<Board>();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: board,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text("CheckGrid", style: TextStyle(fontSize: 30)),
          // Settings button
          actions: [
            SizedBox(
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () {
                  context.read<AudioProvider>().playOpenMenu();
                  showSettingsDialog(board: board, context: context);
                  context.read<SettingsProvider>().doVibration(1);
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
              const SizedBox(height: 20),
              Consumer<Board>(builder: (context, board, _) => GameBoard()),
              const SizedBox(height: 20),
              Consumer<Board>(builder: (context, board, _) => PieceSelector()),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  _buildTutorialButton() ?? const SizedBox(),
                  _buildReviveButton() ?? const SizedBox(),
                  _buildGameOverButton() ?? const SizedBox(),

                  const Spacer(),
                ],
              ),
              const Spacer(),
              //const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // For debug and testing
  Widget? _buildTutorialButton() {
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
            onPressed:
                () => {
                  GeneralProvider.isFirstTimeUser = true,
                  context.pushNamed('/tutorial'),
                },
            child: const Text(
              'Tutorial',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      );
    }
    return null;
  }

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
