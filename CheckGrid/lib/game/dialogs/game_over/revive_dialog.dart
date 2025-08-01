import 'package:checkgrid/game/board.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/components/countdown_loading.dart';
import 'package:go_router/go_router.dart';

Future<void> showReviveDialog(BuildContext context, Board board) async {
  if (board.isReviveShowing) return;

  board.isReviveShowing = true;

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return CountdownLoading(
        board: board,
        afterAd: () async {
          // Om användaren såg klart hela annonsen (revive)
          await board.animatedClearBoard();

          board.spawnInitialActiveCells();
          board.selectedPiecesPositions.clear();
          board.targetedCellsMap.clear();
          board.setNewSelectedPieces();

          board.isGameOver = false;
          board.isReviveShowing = false;
          board.watchedAds++;
        },
      );
    },
  );

  board.isReviveShowing = false;

  if (result == true) {
    await board.animatedClearBoard();
    if (context.mounted) {
      context.go('/gameover', extra: board);
    }
  }
}
