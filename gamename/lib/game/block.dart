import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:gamename/game/piecetype.dart';

class Block {
  Point position;
  bool isActive;
  bool isTargeted;
  bool hasPiece;
  PieceType? piece;
  Color? color;
  
  Block({
    required this.position,
    this.isActive = false, 
    this.isTargeted = false, 
    this.hasPiece = false,
    this.piece, 
    this.color
    });
}
