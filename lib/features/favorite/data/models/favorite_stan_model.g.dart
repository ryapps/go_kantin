// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_stan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteStanModelAdapter extends TypeAdapter<FavoriteStanModel> {
  @override
  final int typeId = 0;

  @override
  FavoriteStanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteStanModel(
      id: fields[0] as String,
      namaStan: fields[1] as String,
      namaPemilik: fields[2] as String,
      description: fields[3] as String,
      imageUrl: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteStanModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaStan)
      ..writeByte(2)
      ..write(obj.namaPemilik)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteStanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
