import 'dart:ui';

import 'package:checkgrid/game/dialogs/game_over/revive_dialog.dart';
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

class _PieceSelectorState extends State<PieceSelector> {
  final double boxWidth = 250;
  final double boxHeight = 100;

  @override
  Widget build(BuildContext context) {
    final board = context.watch<Board>();
    final selectedPieces = board.selectedPieces;

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
            Color.fromARGB(255, 57, 159, 255),
            Color.fromARGB(255, 107, 193, 255),
            Color.fromARGB(255, 111, 192, 215),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: _buildPieceSelector(selectedPieces, board),
    );
  }

  void _handleLastPiece(Board board) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    final tutorial = context.read<TutorialController>();
    if (tutorial.tutorialStep == 4 && tutorial.isActive) {
      await tutorial.nextStep();
      board.selectedPieces = [];
    }

    board.addScore();
    board.removeTargetedCells();
    board.removePlacedPieces();
    board.clearPiecesOnBoard();
    board.setNewSelectedPieces();
    await board.spawnActiveCells();
    board.updateColors();
    board.checkGameOver();

    if (!mounted) return;
    if (board.isGameOver && (board.watchedAds >= 3)) {
      context.go('/gameover', extra: board);
    } else if (board.isGameOver) {
      showReviveDialog(context, board);
    }

    board.updateHighscore(context);
    board.saveBoard(context);
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
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: generalProvider.pieceImage(size, pieceType, null, context),
          ),
        ),
        // Original image
        generalProvider.pieceImage(size, pieceType, null, context),
      ],
    );
  }
}
