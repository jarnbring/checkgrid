import 'dart:async';

import 'package:checkgrid/components/glass_box.dart';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/game_board.dart';
import 'package:checkgrid/game/piece_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late final Board board;
  late final TutorialController tutorial;
  late BuildContext rootContext;

  @override
  void initState() {
    super.initState();
    rootContext = context;
    board = rootContext.read<Board>();
    tutorial = rootContext.read<TutorialController>();
    tutorial.isActive = true;

    tutorial.addListener(() {
      showTutorial();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set a clear board for the tutorial
      board.restartGame(context);
      showTutorial();
    });
  }

  Widget _buildStepDialog({
    required String title,
    required String description,
    required int step,
    required VoidCallback onNext,
  }) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: GlassBox(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              //color: const Color.fromARGB(255, 51, 51, 51),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CupertinoColors.systemBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.8),
                    ),
                    child: Text(
                      tutorial.tutorialStep == 4 ? "Done" : "Next",
                      style: const TextStyle(fontSize: 16),
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

  void showTutorial() async {
    final tutorial = rootContext.read<TutorialController>();

    switch (tutorial.tutorialStep) {
      case 1:
        await showGeneralDialog(
          context: rootContext,
          barrierDismissible: false,
          barrierLabel: "Tutorial",
          pageBuilder: (context, animation, secondaryAnimation) {
            return _buildStepDialog(
              title: "Welcome to CheckGrid!",
              description:
                  "Drag a piece from the selection area below and place it on the gray squares adjacent to the green cells.",
              step: tutorial.tutorialStep,
              onNext: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
        break;
      case 2:
        await showGeneralDialog(
          context: rootContext,
          barrierDismissible: false,
          barrierLabel: "Tutorial",
          pageBuilder: (context, animation, secondaryAnimation) {
            return _buildStepDialog(
              title: "Great Job!",
              description:
                  "Excellent! The X-marked cells will be cleared from the board. Your goal is to prevent cells from reaching the bottom blue zone.\n\nNow place the remaining pieces to continue.",
              step: tutorial.tutorialStep,
              onNext: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
        break;
      case 4:
        await showGeneralDialog(
          context: rootContext,
          barrierDismissible: false,
          barrierLabel: "Tutorial",
          pageBuilder: (context, animation, secondaryAnimation) {
            return _buildStepDialog(
              title: "Tutorial Complete!",
              description:
                  "Perfect! When you place all pieces, the top rows will shift down and new pieces will appear. You're ready to start scoring points.\n\nGood luck and have fun!",
              step: tutorial.tutorialStep,
              onNext: () async {
                Navigator.of(context).pop();
                await Future.delayed(const Duration(milliseconds: 300));
                tutorial.completeStep();
                await Future.delayed(const Duration(milliseconds: 1000));
                if (!mounted) return;
                rootContext.pushNamed('/home');
                board.restartGame(rootContext);
                tutorial.isActive = false;
              },
            );
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: board)],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const GameBoard(),
              const SizedBox(height: 20),
              const PieceSelector(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialController extends ChangeNotifier {
  int tutorialStep = 1;
  bool isActive = false;
  Completer<void>? _stepCompleter;

  Future<void> nextStep() {
    tutorialStep++;
    notifyListeners();
    _stepCompleter = Completer<void>();
    return _stepCompleter!.future;
  }

  void completeStep() {
    _stepCompleter?.complete();
    _stepCompleter = null;
  }
}
