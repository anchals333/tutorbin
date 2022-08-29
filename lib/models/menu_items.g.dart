// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_items.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuItemsAdapter extends TypeAdapter<MenuItems> {
  @override
  final int typeId = 2;

  @override
  MenuItems read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MenuItems(
      name: fields[0] as String,
      price: fields[1] as int,
      instock: fields[2] as bool,
      quantity: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MenuItems obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.instock)
      ..writeByte(3)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
