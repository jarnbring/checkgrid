import 'dart:math';
import 'package:checkgrid/providers/board_storage.dart';
import 'package:flutter/material.dart';

class BoardProvider with ChangeNotifier {
  // Behåll för kompatibilitet men delegera till GameStorage

  // Statistik metoder
  Future<void> incrementRounds() async {
    await GameStorage.incrementRounds();
    notifyListeners();
  }

  Future<void> incrementPlacedPieces() async {
    await GameStorage.incrementPlacedPieces();
    notifyListeners();
  }

  Future<Map<String, int>> getStatistics() async {
    return await GameStorage.getStatistics();
  }

  // Highscore metoder
  Future<void> saveHighScore(BigInt score) async {
    await GameStorage.saveHighScore(score);
    notifyListeners();
  }

  Future<BigInt> getHighScore() async {
    return await GameStorage.getHighScore();
  }

  // Speldata metoder
  Future<void> saveCurrentGame({
    required Map<String, dynamic> boardData,
    required Map<String, dynamic> targetedCellsMap,
    required List<String> selectedPieces,
    required List<Point<int>> selectedPiecesPositions,
    required String difficulty,
    required int watchedAds,
    required bool isGameOver,
    required bool isReviveShowing,
    required String currentScore,
    required int currentCombo,
  }) async {
    await GameStorage.saveCurrentGame(
      boardData: boardData,
      targetedCellsMap: targetedCellsMap,
      selectedPieces: selectedPieces,
      selectedPiecesPositions: selectedPiecesPositions,
      difficulty: difficulty,
      watchedAds: watchedAds,
      isGameOver: isGameOver,
      isReviveShowing: isReviveShowing,
      currentScore: currentScore,
      currentCombo: currentCombo,
    );
    notifyListeners();
  }

  Future<Map<String, dynamic>?> loadCurrentGame() async {
    return await GameStorage.loadCurrentGame();
  }

  Future<void> clearCurrentGame() async {
    await GameStorage.clearCurrentGame();
    notifyListeners();
  }

  Future<void> clearAllLocalData() async {
    await GameStorage.clearCurrentGame();
    notifyListeners();
  }
}
