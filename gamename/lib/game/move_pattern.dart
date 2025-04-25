enum Direction {
  up,
  down,
  left,
  right,
  upLeft,
  upRight,
  downLeft,
  downRight,
  knightLShape,  // För hästen
}

class MovePattern {
  final List<Direction> directions;
  final bool canMoveMultipleSquares;

  MovePattern({required this.directions, this.canMoveMultipleSquares = true});
}
