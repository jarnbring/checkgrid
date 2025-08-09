import 'dart:ui' show Offset;
import 'package:checkgrid/game/utilities/move_pattern.dart';
import 'package:hive/hive.dart';

part 'piecetype.g.dart';

@HiveType(typeId: 1)
enum PieceType {
  @HiveField(0)
  pawn,
  @HiveField(1)
  knight,
  @HiveField(2)
  bishop,
  @HiveField(3)
  rook,
  @HiveField(4)
  queen,
  @HiveField(5)
  king,
}

class PlacedPiece {
  final PieceType type;
  final int row;
  final int col;

  PlacedPiece({required this.type, required this.row, required this.col});
}

extension PieceProperties on PieceType {
  MovePattern get movementPattern {
    switch (this) {
      case PieceType.king:
        return MovePattern(
          directions: [
            Direction.up,
            Direction.down,
            Direction.left,
            Direction.right,
            Direction.upLeft,
            Direction.upRight,
            Direction.downLeft,
            Direction.downRight,
          ],
          canMoveMultipleSquares: false,
        );
      case PieceType.queen:
        return MovePattern(
          directions: [
            Direction.up,
            Direction.down,
            Direction.left,
            Direction.right,
            Direction.upLeft,
            Direction.upRight,
            Direction.downLeft,
            Direction.downRight,
          ],
        );
      case PieceType.rook:
        return MovePattern(
          directions: [
            Direction.up,
            Direction.down,
            Direction.left,
            Direction.right,
          ],
        );
      case PieceType.bishop:
        return MovePattern(
          directions: [
            Direction.upLeft,
            Direction.upRight,
            Direction.downLeft,
            Direction.downRight,
          ],
        );
      case PieceType.knight:
        return MovePattern(
          directions: [Direction.knightLShape],
          canMoveMultipleSquares: false,
        );
      case PieceType.pawn:
        return MovePattern(
          directions: [Direction.upLeft, Direction.upRight],
          canMoveMultipleSquares: false,
        );
    }
  }
}

extension DirectionMovement on Direction {
  List<Offset> get offsets {
    switch (this) {
      case Direction.up:
        return [Offset(0, -1)];
      case Direction.down:
        return [Offset(0, 1)];
      case Direction.left:
        return [Offset(-1, 0)];
      case Direction.right:
        return [Offset(1, 0)];
      case Direction.upLeft:
        return [Offset(-1, -1)];
      case Direction.upRight:
        return [Offset(1, -1)];
      case Direction.downLeft:
        return [Offset(-1, 1)];
      case Direction.downRight:
        return [Offset(1, 1)];
      case Direction.knightLShape:
        return [
          Offset(2, 1),
          Offset(2, -1),
          Offset(-2, 1),
          Offset(-2, -1),
          Offset(1, 2),
          Offset(1, -2),
          Offset(-1, 2),
          Offset(-1, -2),
        ];
    }
  }
}
