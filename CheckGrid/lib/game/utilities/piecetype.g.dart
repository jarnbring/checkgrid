// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piecetype.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PieceTypeAdapter extends TypeAdapter<PieceType> {
  @override
  final int typeId = 1;

  @override
  PieceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PieceType.pawn;
      case 1:
        return PieceType.knight;
      case 2:
        return PieceType.bishop;
      case 3:
        return PieceType.rook;
      case 4:
        return PieceType.queen;
      case 5:
        return PieceType.king;
      default:
        return PieceType.pawn;
    }
  }

  @override
  void write(BinaryWriter writer, PieceType obj) {
    switch (obj) {
      case PieceType.pawn:
        writer.writeByte(0);
        break;
      case PieceType.knight:
        writer.writeByte(1);
        break;
      case PieceType.bishop:
        writer.writeByte(2);
        break;
      case PieceType.rook:
        writer.writeByte(3);
        break;
      case PieceType.queen:
        writer.writeByte(4);
        break;
      case PieceType.king:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PieceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
