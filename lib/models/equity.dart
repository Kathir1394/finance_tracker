import 'package:hive/hive.dart';

part 'equity.g.dart'; // This file will be generated

@HiveType(typeId: 2)
class Equity extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String ticker;

  @HiveField(2)
  late String companyName;

  @HiveField(3)
  late int quantity;

  @HiveField(4)
  late double buyPrice;

  @HiveField(5)
  late DateTime purchaseDate;

  @HiveField(6)
  double? sellPrice;

  @HiveField(7)
  DateTime? saleDate;

  Equity({
    required this.id,
    required this.ticker,
    required this.companyName,
    required this.quantity,
    required this.buyPrice,
    required this.purchaseDate,
    this.sellPrice,
    this.saleDate,
  });
}