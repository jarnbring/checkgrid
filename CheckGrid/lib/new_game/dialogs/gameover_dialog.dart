import 'package:checkgrid/new_game/board.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/components/countdown_loading.dart';
  
  void showGameOverDialog(BuildContext context, Board board) {
    if (!board.isReviveShowing) {
      board.isReviveShowing = true;

      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) {
          return CountdownLoading(
            afterAd: () {
              // Reset board
              // SpawnNewInitCells
              // selectedPiecesPositions.clear();
              // targetedCellsMap.clear();
              // SetNewPieces
              // isGameOver = false
              // isReviveShowing = false

            },
            onRestart: board.restartGame,
            isReviveShowing: board.isReviveShowing,
          );
        },
      ).then((_) {
        board.isReviveShowing = false;
      });
    }
  }
