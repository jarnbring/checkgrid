import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Handles async methods for the board, i.e save, load

class BoardProvider with ChangeNotifier {
  late Box _boardBox;
  late Box _statisticsBox;

  int _writeCounter = 0;

  late Future<void> initFuture;

  BoardProvider() {
    initFuture = _initHive();
  }

  Future<void> _initHive() async {
    // Enable on-the-fly compaction when many tombstones accumulate
    _boardBox = await Hive.openBox(
      'boardBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 1000,
    );
    _statisticsBox = await Hive.openBox(
      'statisticsBox',
      compactionStrategy: (entries, deletedEntries) => deletedEntries > 200,
    );
  }

  Box get getBoardBox => _boardBox;
  Box get getStatisticsBox => _statisticsBox;

  // Register a logical write; periodically compact to reclaim space
  Future<void> registerWrite() async {
    _writeCounter++;
    if (_writeCounter % 200 == 0) {
      await compactAll();
    }
  }

  Future<void> compactAll() async {
    try {
      await _boardBox.compact();
      await _statisticsBox.compact();
    } catch (_) {
      // ignore
    }
  }

  Future<void> clearAllLocalData() async {
    await _boardBox.clear();
    await _statisticsBox.clear();
    await compactAll();
  }
}
