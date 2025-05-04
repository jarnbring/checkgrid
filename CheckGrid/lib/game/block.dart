import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamename/game/piecetype.dart';

class Block {
  Point<int> position;
  bool isActive;
  bool isTargeted;
  bool hasPiece;
  PieceType? piece;
  Gradient? gradient;
  Color? fallbackColor;

  Block({
    required this.position,
    this.isActive = false,
    this.isTargeted = false,
    this.hasPiece = false,
    this.piece,
    this.gradient,
    this.fallbackColor,
  });

  Map<String, dynamic> toJson() => {
        'position': {'x': position.x, 'y': position.y},
        'isActive': isActive,
        'isTargeted': isTargeted,
        'hasPiece': hasPiece,
        'piece': piece?.name,
        'color': fallbackColor?.value,
      };

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        position: Point<int>(
          json['position']['x'] as int,
          json['position']['y'] as int,
        ),
        isActive: json['isActive'] as bool,
        isTargeted: json['isTargeted'] as bool,
        hasPiece: json['hasPiece'] as bool,
        piece: json['piece'] != null
            ? PieceType.values.firstWhere((e) => e.name == json['piece'])
            : null,
        fallbackColor: json['color'] != null ? Color(json['color'] as int) : null,
      );
}