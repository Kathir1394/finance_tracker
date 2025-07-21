import 'package:hive/hive.dart';

part 'derivative.g.dart'; // This file will be generated

@HiveType(typeId: 3)
enum TradeType {
  @HiveField(0)
  intraday,
  @HiveField(1)
  positional,
}

@HiveType(typeId: 4)
class DerivativeTrade extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String instrument;

  @HiveField(2)
  late TradeType tradeType;

  @HiveField(3)
  late DateTime buyDate;

  @HiveField(4)
  DateTime? saleDate;

  @HiveField(5)
  late double netPandL;

  @HiveField(6)
  String? strategy;

  @HiveField(7)
  String? learnings;

  DerivativeTrade({
    required this.id,
    required this.instrument,
    required this.tradeType,
    required this.buyDate,
    this.saleDate,
    required this.netPandL,
    this.strategy,
    this.learnings,
  });
}