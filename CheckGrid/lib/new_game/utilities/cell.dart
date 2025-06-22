import 'dart:math';
import 'package:checkgrid/new_game/utilities/piecetype.dart';
import 'package:flutter/material.dart';

class Cell extends ChangeNotifier {
  Point<int> position;
  bool _isActive;
  bool _isTargeted;
  bool _hasPiece;
  bool isPreview = false;
  PieceType? _piece;
  Color _color;

  Cell({
    required this.position,
    bool isActive = false,
    bool isTargeted = false,
    bool hasPiece = false,
    PieceType? piece,
    Color color = Colors.grey,
  }) : _isActive = isActive,
       _isTargeted = isTargeted,
       _hasPiece = hasPiece,
       _piece = piece,
       _color = color;

  bool get isActive => _isActive;
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      notifyListeners();
    }
  }

  bool get isTargeted => _isTargeted;
  set isTargeted(bool value) {
    if (_isTargeted != value) {
      _isTargeted = value;
      notifyListeners();
    }
  }

  bool get hasPiece => _hasPiece;
  set hasPiece(bool value) {
    if (_hasPiece != value) {
      _hasPiece = value;
      notifyListeners();
    }
  }

  PieceType? get piece => _piece;
  set piece(PieceType? value) {
    if (_piece != value) {
      _piece = value;
      hasPiece = value != null;
      notifyListeners();
    }
  }

  Color get color => _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      notifyListeners();
    }
  }

  Map<String, dynamic> toJson() => {
    'position': {'x': position.x, 'y': position.y},
    'isActive': isActive,
    'isTargeted': isTargeted,
    'hasPiece': hasPiece,
    'piece': piece?.name,
  };

  factory Cell.fromJson(Map<String, dynamic> json) => Cell(
    position: Point<int>(
      json['position']['x'] as int,
      json['position']['y'] as int,
    ),
    isActive: json['isActive'] as bool,
    isTargeted: json['isTargeted'] as bool,
    hasPiece: json['hasPiece'] as bool,
    piece:
        json['piece'] != null
            ? PieceType.values.firstWhere((e) => e.name == json['piece'])
            : null,
  );
}
