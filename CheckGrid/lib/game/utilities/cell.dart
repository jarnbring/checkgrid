import 'dart:math';
import 'package:checkgrid/game/utilities/piecetype.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'cell.g.dart';

@HiveType(typeId: 0)
class Cell extends HiveObject with ChangeNotifier {
  @HiveField(0)
  late int x;

  @HiveField(1)
  late int y;

  @HiveField(2)
  bool _isActive;

  @HiveField(3)
  bool _isTargeted;

  @HiveField(4)
  bool _hasPiece;

  @HiveField(5)
  bool isPreview;

  @HiveField(6)
  PieceType? _piece;

  @HiveField(7)
  int colorValue;

  Gradient? _gradient;

  Cell({
    Point<int>? position,
    bool isActive = false,
    bool isTargeted = false,
    bool hasPiece = false,
    this.isPreview = false,
    PieceType? piece,
    Color color = Colors.grey,
  }) : x = position?.x ?? 0,
       y = position?.y ?? 0,
       _isActive = isActive,
       _isTargeted = isTargeted,
       _hasPiece = hasPiece,
       _piece = piece,
       colorValue = color.value;

  Point<int> get position => Point<int>(x, y);

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

  // Getter för färg/gradient
  Color get color => Color(colorValue);
  Gradient? get gradient => _gradient;

  // Setter för Color
  set color(Color value) {
    if (colorValue != value.value) {
      colorValue = value.value;
      _gradient = null; // Nollställ gradient
      notifyListeners();
    }
  }

  // Setter för Gradient
  set gradient(Gradient? value) {
    if (_gradient != value) {
      _gradient = value;
      notifyListeners();
    }
  }

  // Helper method för att kolla om cell har gradient
  bool get hasGradient => _gradient != null;

  // Helper method för att få decoration
  Decoration getDecoration() {
    if (hasGradient) {
      return BoxDecoration(gradient: _gradient);
    } else {
      return BoxDecoration(color: color);
    }
  }
}
