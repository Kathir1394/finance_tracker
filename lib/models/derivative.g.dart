// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'derivative.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DerivativeTradeAdapter extends TypeAdapter<DerivativeTrade> {
  @override
  final int typeId = 4;

  @override
  DerivativeTrade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DerivativeTrade(
      id: fields[0] as String,
      instrument: fields[1] as String,
      tradeType: fields[2] as TradeType,
      buyDate: fields[3] as DateTime,
      saleDate: fields[4] as DateTime?,
      netPandL: fields[5] as double,
      strategy: fields[6] as String?,
      learnings: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DerivativeTrade obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.instrument)
      ..writeByte(2)
      ..write(obj.tradeType)
      ..writeByte(3)
      ..write(obj.buyDate)
      ..writeByte(4)
      ..write(obj.saleDate)
      ..writeByte(5)
      ..write(obj.netPandL)
      ..writeByte(6)
      ..write(obj.strategy)
      ..writeByte(7)
      ..write(obj.learnings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DerivativeTradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TradeTypeAdapter extends TypeAdapter<TradeType> {
  @override
  final int typeId = 3;

  @override
  TradeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TradeType.intraday;
      case 1:
        return TradeType.positional;
      default:
        return TradeType.intraday;
    }
  }

  @override
  void write(BinaryWriter writer, TradeType obj) {
    switch (obj) {
      case TradeType.intraday:
        writer.writeByte(0);
        break;
      case TradeType.positional:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
