import 'dart:ui';

import 'package:checkgrid/game/dialogs/revive_dialog.dart';
import 'package:checkgrid/pages/tutorial_page.dart';
import 'package:checkgrid/providers/audio_provider.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/utilities/piecetype.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PieceSelector extends StatefulWidget {
  const PieceSelector({super.key});

  @override
  State<PieceSelector> createState() => _PieceSelectorState();
}

class _PieceSelectorState extends State<PieceSelector>
    with SingleTickerProviderStateMixin {
  final double boxWidth = 250;
  final double boxHeight = 100;

  // Animation controller för fadein
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Skapa animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Skapa fade animation med mjuk kurva
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = context.watch<Board>();
    final selectedPieces = board.selectedPieces;

    // Starta animation när nya pjäser animeras
    if (board.isAnimatingNewPieces && !_animationController.isAnimating) {
      _animationController.forward(from: 0.0);
    }

    return Container(
      width: boxWidth,
      height: boxHeight,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: BoxBorder.all(color: Colors.black, width: 4),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black45,
            offset: Offset(0, 0),
          ),
        ],
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 81, 168, 249),
            Color.fromARGB(255, 107, 193, 255),
            Color.fromARGB(255, 111, 192, 215),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: _buildPieceSelector(selectedPieces, board),
    );
  }

  void _handleLastPiece(Board board) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final tutorial = context.read<TutorialController>();
    if (tutorial.tutorialStep == 4 && tutorial.isActive) {
      await tutorial.nextStep();
      board.selectedPieces = [];
    }

    // Starta addScore men vänta inte här
    final addScoreFuture = board.addScore();

    board.removeTargetedCells();
    board.removePlacedPieces();
    await board.spawnActiveCells();
    board.updateColors();

    if (!mounted) return;
    board.setNewSelectedPieces();
    board.updateHighscore(context);

    if (board.isGameOver && (board.watchedAds >= 3)) {
      board.resetScore();
      await board.animatedClearBoard();
      if (!mounted) return;
      context.go('/gameover', extra: board);
    } else if (board.isGameOver) {
      showReviveDialog(context, board);
    }

    // Vänta att animationen i addScore ska bli klar **innan** sparandet
    await addScoreFuture;
    if (!mounted) return;
    await board.saveBoard(context);
  }

  Widget _buildPieceSelector(List<PieceType> selectedPieces, Board board) {
    final generalProvider = context.watch<GeneralProvider>();
    final largePieceIconSize = generalProvider.pieceInSelectorSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          selectedPieces.map((pieceType) {
            Offset? dragStartLocalPosition;

            return Flexible(
              child: StatefulBuilder(
                builder: (context, setLocalState) {
                  return GestureDetector(
                    onPanStart: (details) {
                      setLocalState(() {
                        dragStartLocalPosition = details.localPosition;
                      });
                    },
                    onPanEnd: (_) {
                      setLocalState(() {
                        dragStartLocalPosition = null;
                      });
                    },
                    child: Draggable<PieceType>(
                      data: pieceType,
                      onDragStarted:
                          () => context.read<AudioProvider>().playPickUpPiece(),
                      feedback:
                          dragStartLocalPosition == null
                              ? _buildShadowedPiece(
                                generalProvider,
                                largePieceIconSize,
                                pieceType,
                                context,
                              )
                              : Transform.translate(
                                offset: -dragStartLocalPosition!,
                                child: _buildShadowedPiece(
                                  generalProvider,
                                  largePieceIconSize,
                                  pieceType,
                                  context,
                                ),
                              ),
                      feedbackOffset:
                          dragStartLocalPosition == null
                              ? Offset.zero
                              : -dragStartLocalPosition!,
                      childWhenDragging: Opacity(
                        opacity: 0.2,
                        child: _buildShadowedPiece(
                          generalProvider,
                          largePieceIconSize,
                          pieceType,
                          context,
                        ),
                      ),
                      onDragEnd: (dragDetails) {
                        setLocalState(() {
                          dragStartLocalPosition = null;
                        });
                        if (selectedPieces.isEmpty) _handleLastPiece(board);
                      },
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          // Använd bara animation om vi animerar nya pjäser
                          final opacity =
                              board.isAnimatingNewPieces
                                  ? _fadeAnimation.value
                                  : 1.0;

                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale:
                                  board.isAnimatingNewPieces
                                      ? 0.8 + (0.2 * _fadeAnimation.value)
                                      : 1.0,
                              child: _buildShadowedPiece(
                                generalProvider,
                                largePieceIconSize,
                                pieceType,
                                context,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
    );
  }

  Widget _buildShadowedPiece(
    GeneralProvider generalProvider,
    double size,
    PieceType pieceType,
    BuildContext context,
  ) {
    return Stack(
      children: [
        // Fake a shadow
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: generalProvider.pieceImage(size, pieceType, null, context),
          ),
        ),
        // Original image
        generalProvider.pieceImage(size, pieceType, null, context),
      ],
    );
  }
}
