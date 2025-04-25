import 'package:gamename/game/move_pattern.dart';

enum PieceType { king, queen, rook, bishop, knight, pawn }

extension PieceProperties on PieceType {

  MovePattern get movementPattern {
    switch (this) {
      case PieceType.king:
        return MovePattern(
          directions: [Direction.up, Direction.down, Direction.left, Direction.right, Direction.upLeft, Direction.upRight, Direction.downLeft, Direction.downRight],
          canMoveMultipleSquares: false,
        );
      case PieceType.queen:
        return MovePattern(
          directions: [Direction.up, Direction.down, Direction.left, Direction.right, Direction.upLeft, Direction.upRight, Direction.downLeft, Direction.downRight],
        );
      case PieceType.rook:
        return MovePattern(
          directions: [Direction.up, Direction.down, Direction.left, Direction.right],
        );
      case PieceType.bishop:
        return MovePattern(
          directions: [Direction.upLeft, Direction.upRight, Direction.downLeft, Direction.downRight],
        );
      case PieceType.knight:
        return MovePattern(
          directions: [Direction.knightLShape], // Specifik rörelse för hästen
          canMoveMultipleSquares: false,
        );
      case PieceType.pawn:
        return MovePattern(
          directions: [Direction.up], // Bonden rör sig en ruta framåt
          canMoveMultipleSquares: false,
        );
    }
  }
}
