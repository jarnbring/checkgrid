import 'package:checkgrid/game/board.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/components/countdown_loading.dart';

void showReviveDialog(BuildContext context, Board board) async {
  if (board.isReviveShowing) return;

  board.isReviveShowing = true;

  showGeneralDialog(
    context: context,
    transitionDuration: const Duration(milliseconds: 1000),
    pageBuilder: (_, _, _) {
      return CountdownLoading(
        board: board,
        afterAd: () {
          // This is if the user watched the whole ad (award)

          // Reset board
          board.clearBoard();

          // SpawnNewInitCells
          board.spawnInitialActiveCells();

          // selectedPiecesPositions.clear();
          board.selectedPiecesPositions.clear();

          // targetedCellsMap.clear();
          board.targetedCellsMap.clear();

          // SetNewPieces
          board.setNewSelectedPieces();

          board.isGameOver = false;
          board.isReviveShowing = false;
          board.watchedAds++;
        },
      );
    },
  ).then((_) {
    board.isReviveShowing = false;
  });
}
