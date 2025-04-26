import 'package:gamename/game/piecetype.dart';

class Block {
  bool isActive;
  bool isTargeted;
  PieceType? piece;

  Block({this.isActive = false, this.isTargeted = false, this.piece});
}
