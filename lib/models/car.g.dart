// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CarAdapter extends TypeAdapter<Car> {
  @override
  final int typeId = 0;

  @override
  Car read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Car(
      model: fields[0] as String,
      description: fields[1] as String,
      year: fields[2] as int,
      images: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Car obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.model)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
