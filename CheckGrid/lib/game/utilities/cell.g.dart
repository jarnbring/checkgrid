// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CellAdapter extends TypeAdapter<Cell> {
  @override
  final int typeId = 0;

  @override
  Cell read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cell(
      isPreview: fields[5] as bool,
    )
      ..x = fields[0] as int
      ..y = fields[1] as int
      .._isActive = fields[2] as bool
      .._isTargeted = fields[3] as bool
      .._hasPiece = fields[4] as bool
      .._piece = fields[6] as PieceType?
      ..colorValue = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, Cell obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.x)
      ..writeByte(1)
      ..write(obj.y)
      ..writeByte(2)
      ..write(obj._isActive)
      ..writeByte(3)
      ..write(obj._isTargeted)
      ..writeByte(4)
      ..write(obj._hasPiece)
      ..writeByte(5)
      ..write(obj.isPreview)
      ..writeByte(6)
      ..write(obj._piece)
      ..writeByte(7)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
