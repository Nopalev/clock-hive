// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worldtime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorldTimeAdapter extends TypeAdapter<WorldTime> {
  @override
  final int typeId = 0;

  @override
  WorldTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorldTime(
      url: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorldTime obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
