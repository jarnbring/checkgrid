// === lib/providers/game_storage.dart ===
// (Som tidigare, men nu med Point import)

import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class GameStorage with ChangeNotifier {
  static const String _gameFile = 'current_game.json';

  // === PERMANENT DATA (SharedPreferences) ===

  static Future<void> saveHighScore(BigInt score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('highscore', score.toString());
  }

  static Future<BigInt> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final scoreStr = prefs.getString('highscore') ?? '0';
    return BigInt.parse(scoreStr);
  }

  static Future<void> saveDifficulty(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', difficulty);
  }

  static Future<String> getDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('difficulty') ?? 'medium';
  }

  // Statistik
  static Future<void> incrementRounds() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('stat_rounds') ?? 0;
    await prefs.setInt('stat_rounds', current + 1);
  }

  static Future<void> incrementPlacedPieces() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('stat_pieces') ?? 0;
    await prefs.setInt('stat_pieces', current + 1);
  }

  static Future<Map<String, int>> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'amountOfRounds': prefs.getInt('stat_rounds') ?? 0,
      'placedPieces': prefs.getInt('stat_pieces') ?? 0,
    };
  }

  // === TILLFÄLLIG SPELDATA (JSON-fil) ===

  static Future<File> _getGameFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_gameFile');
  }

  static Future<void> saveCurrentGame({
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
    try {
      final gameData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'board': boardData,
        'targetedCellsMap': targetedCellsMap,
        'selectedPieces': selectedPieces,
        'selectedPiecesPositions':
            selectedPiecesPositions.map((p) => {'x': p.x, 'y': p.y}).toList(),
        'difficulty': difficulty,
        'watchedAds': watchedAds,
        'isGameOver': isGameOver,
        'isReviveShowing': isReviveShowing,
        'currentScore': currentScore,
        'currentCombo': currentCombo,
      };

      final file = await _getGameFile();
      await file.writeAsString(jsonEncode(gameData));

      final size = await file.length();
      debugPrint('✅ Game saved: $size bytes');
    } catch (e) {
      debugPrint('❌ Save game error: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadCurrentGame() async {
    try {
      final file = await _getGameFile();
      if (!await file.exists()) return null;

      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;

      return data;
    } catch (e) {
      debugPrint('❌ Load game error: $e');
      await clearCurrentGame();
      return null;
    }
  }

  static Future<void> clearCurrentGame() async {
    try {
      final file = await _getGameFile();
      if (await file.exists()) {
        final sizeBefore = await file.length();
        await file.delete();
        debugPrint('🗑️ Game file deleted: $sizeBefore bytes freed');
      }
    } catch (e) {
      debugPrint('❌ Clear game error: $e');
    }
  }

  static Future<void> debugFileSize() async {
    try {
      final file = await _getGameFile();
      if (await file.exists()) {
        final size = await file.length();
        debugPrint('📊 Current game file: $size bytes');
      } else {
        debugPrint('📊 No game file exists');
      }
    } catch (e) {
      debugPrint('❌ File size check error: $e');
    }
  }
}
