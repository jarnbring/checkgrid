import 'package:checkgrid/game/dialogs/game_over/revive_dialog.dart';
import 'package:checkgrid/pages/tutorial_page.dart';
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
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 57, 159, 255),
            Color.fromARGB(255, 111, 185, 255),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child:
          selectedPieces.isEmpty
              ? _buildContinue(board)
              : _buildPieceSelector(selectedPieces),
    );
  }

  // Builds a row of draggable chess pieces that the player can pick and place on the board
  Widget _buildPieceSelector(List<PieceType> selectedPieces) {
    final generalProvider = context.watch<GeneralProvider>();
    final largePieceIconSize = generalProvider.pieceInSelectorSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          selectedPieces.map((pieceType) {
            Offset?
            dragStartLocalPosition; // Stores where the drag started for offset adjustments

            return Flexible(
              child: StatefulBuilder(
                builder: (context, setLocalState) {
                  return GestureDetector(
                    // Called when user starts dragging a piece
                    onPanStart: (details) {
                      setLocalState(() {
                        dragStartLocalPosition = details.localPosition;
                      });
                    },
                    // Called when the drag ends
                    onPanEnd: (_) {
                      setLocalState(() {
                        dragStartLocalPosition = null;
                      });
                    },
                    child: Draggable<PieceType>(
                      data: pieceType, // This is the piece type being dragged
                      // The visual shown while dragging
                      feedback:
                          dragStartLocalPosition == null
                              ? generalProvider.pieceImage(
                                largePieceIconSize,
                                pieceType,
                                null,
                                context,
                              )
                              : Transform.translate(
                                // Offsets the image so it appears correctly under the finger
                                offset: -dragStartLocalPosition!,
                                // + extraVisualOffset,
                                child: generalProvider.pieceImage(
                                  largePieceIconSize,
                                  pieceType,
                                  null,
                                  context,
                                ),
                              ),

                      // Where the feedback should appear relative to the finger
                      feedbackOffset:
                          dragStartLocalPosition == null
                              ? Offset.zero
                              : -dragStartLocalPosition!,
                      // + extraVisualOffset,

                      // The appearance of the original piece during dragging
                      childWhenDragging: Opacity(
                        opacity: 0.2,
                        child: generalProvider.pieceImage(
                          largePieceIconSize,
                          pieceType,
                          null,
                          context,
                        ),
                      ),

                      // Called after the drag is completed
                      onDragEnd: (dragDetails) {
                        setLocalState(() {
                          dragStartLocalPosition = null;
                        });
                      },

                      // The static piece image shown in the selector
                      child: generalProvider.pieceImage(
                        largePieceIconSize,
                        pieceType,
                        null,
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

  Widget _buildContinue(Board board) {
    return GestureDetector(
      onTap: () async {
        // Add score
        board.addScore();

        // Clear old state
        board.removeTargetedCells();
        board.removePlacedPieces();

        // Lägg till denna rad för att rensa ALLA pjäser på brädet:
        board.clearPiecesOnBoard();

        // Create a new state
        board.setNewSelectedPieces();
        await board.spawnActiveCells();

        // Update colors on the board
        board.updateColors();

        // Check if the game is over
        board.checkGameOver();

        if (!mounted) return;

        // If the game was over, show the dialogs
        if (board.isGameOver && (board.watchedAds <= 3)) {
          showReviveDialog(context, board);
        } else if (board.isGameOver) {
          context.go('/gameover', extra: board);
        }

        final tutorial = context.read<TutorialController>();
        if (tutorial.tutorialStep == 4) {
          tutorial.nextStep();
          board.selectedPieces = [];
          return;
        }

        board.updateHighscore(context);
      },
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(color: Colors.transparent),
        alignment: Alignment.center,
        child: const Text(
          "Continue",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
