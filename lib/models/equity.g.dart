// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquityAdapter extends TypeAdapter<Equity> {
  @override
  final int typeId = 2;

  @override
  Equity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Equity(
      id: fields[0] as String,
      ticker: fields[1] as String,
      companyName: fields[2] as String,
      quantity: fields[3] as int,
      buyPrice: fields[4] as double,
      purchaseDate: fields[5] as DateTime,
      sellPrice: fields[6] as double?,
      saleDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Equity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ticker)
      ..writeByte(2)
      ..write(obj.companyName)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.buyPrice)
      ..writeByte(5)
      ..write(obj.purchaseDate)
      ..writeByte(6)
      ..write(obj.sellPrice)
      ..writeByte(7)
      ..write(obj.saleDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
