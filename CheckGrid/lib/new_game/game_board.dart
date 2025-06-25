import 'package:checkgrid/new_game/utilities/cell.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/new_game/board.dart';
import 'package:checkgrid/new_game/utilities/piecetype.dart';
import 'package:provider/provider.dart';

// Handle the board UI, layout etc.

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<Board>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GeneralProvider.boardWidth,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
        ),
        itemCount: GeneralProvider.boardHeight * GeneralProvider.boardWidth,
        itemBuilder: (context, index) {
          final row = index ~/ GeneralProvider.boardWidth;
          final col = index % GeneralProvider.boardWidth;
          return ChangeNotifierProvider<Cell>.value(
            value: board.board[row][col],
            child: BoardCell(row: row, col: col), // Cell
          );
        },
      ),
    );
  }
}

class BoardCell extends StatelessWidget {
  final int row, col;

  const BoardCell({super.key, required this.row, required this.col});

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.read<GeneralProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final board = context.read<Board>();

    return Consumer<Cell>(
      builder: (context, cell, _) {
        return DragTarget<PieceType>(
          onWillAcceptWithDetails: (details) {
            board.previewTargetedCells(details.data, row, col);
            // Returnera true/false beroende på om cellen är tillgänglig
            return !cell.hasPiece && !cell.isActive;
          },
          onLeave: (_) {
            board.clearPreview();
          },
          onAcceptWithDetails: (details) {
            board.placePiece(details.data, row, col);
            board.markTargetedCells(details.data, row, col);
            board.clearPreview();
            board.updateColors(); // Needed for the blue color of the piece
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              decoration: BoxDecoration(
                // Måste uppdatera färger korrekt!
                color: cell.color,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Stack(
                children: [
                  if (cell.piece != null)
                    Image.asset(
                      'assets/images/pieces/${settingsProvider.isDarkPieces ? 'black' : 'white'}/${settingsProvider.isDarkPieces ? 'black' : 'white'}_${cell.piece!.name}.png',
                      width: generalProvider.iconSize,
                      height: generalProvider.iconSize,
                    ),
                  if (cell.isPreview || cell.isTargeted)
                    Opacity(
                      opacity: cell.isTargeted ? 1.0 : 0.5,
                      child: Image.asset(
                        'assets/images/cross.png',
                        width: generalProvider.iconSize,
                        height: generalProvider.iconSize,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
