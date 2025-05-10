import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamename/game/piecetype.dart';

class Block {
  Point<int> position;
  bool isActive;
  bool isTargeted;
  bool isPreview; // Ny egenskap för förhandsvisning
  bool hasPiece;
  PieceType? piece;
  Gradient? gradient;
  Color? fallbackColor;

  Block({
    required this.position,
    this.isActive = false,
    this.isTargeted = false,
    this.isPreview = false,
    this.hasPiece = false,
    this.piece,
    this.gradient,
    this.fallbackColor,
  });

  Map<String, dynamic> toJson() => {
        'position': {'x': position.x, 'y': position.y},
        'isActive': isActive,
        'isTargeted': isTargeted,
        'isPreview': isPreview,
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
        isPreview: json['isPreview'] as bool? ?? false,
        hasPiece: json['hasPiece'] as bool,
        piece: json['piece'] != null
            ? PieceType.values.firstWhere((e) => e.name == json['piece'])
            : null,
        fallbackColor: json['color'] != null ? Color(json['color'] as int) : null,
      );
}

class GlossyBlockPainter extends CustomPainter {
  final Gradient? gradient;
  final double glossPosition;
  final Color? fallbackColor;

  GlossyBlockPainter({
    this.gradient,
    required this.glossPosition,
    this.fallbackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else if (fallbackColor != null) {
      paint.color = fallbackColor!;
    } else {
      paint.color = Colors.grey;
    }

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(5),
    );

    canvas.drawRRect(rect, paint);

    if (gradient != null) {
      final glossPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(
        Offset(size.width * glossPosition, size.height * glossPosition),
        size.width * 0.2,
        glossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}