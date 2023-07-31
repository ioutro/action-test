// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaborator.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollaboratorAdapter extends TypeAdapter<Collaborator> {
  @override
  final int typeId = 0;

  @override
  Collaborator read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Collaborator(
      id: fields[0] as String,
      name: fields[1] as String,
      personalId: fields[2] as int,
      biometric: (fields[3] as List).cast<double>(),
      pic: (fields[4] as List).cast<int>(),
      createdAt: fields[5] as String,
      faker: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Collaborator obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.personalId)
      ..writeByte(3)
      ..write(obj.biometric)
      ..writeByte(4)
      ..write(obj.pic)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.faker);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollaboratorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
