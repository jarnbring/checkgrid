import 'dart:math';
import 'package:gamename/game/piecetype.dart';
import 'package:flutter/material.dart';

class Block {
  bool isActive = false;  // If true, the cell is a killing cell
  final PieceType? piece;
  final Color color;

  Block({required this.isActive, this.piece}) : color = getRandomColor();  

  static Color getRandomColor() {
    final random = Random();
    switch (random.nextInt(3)) {
      case 0:
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }
}
