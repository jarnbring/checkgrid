import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Handles async methods for the board, i.e save, load

class BoardProvider with ChangeNotifier {
  late Box _boardBox;
  late Box _statisticsBox;

  late Future<void> initFuture;

  BoardProvider() {
    initFuture = _initHive();
  }

  Future<void> _initHive() async {
    _boardBox = await Hive.openBox('boardBox');
    _statisticsBox = await Hive.openBox('statisticsBox');
  }

  Box get getBoardBox => _boardBox;
  Box get getStatisticsBox => _statisticsBox;
}
