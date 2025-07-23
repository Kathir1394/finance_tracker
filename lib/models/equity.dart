import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'equity.g.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticker': ticker,
      'companyName': companyName,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'purchaseDate': purchaseDate.toIso8601String(),
      'sellPrice': sellPrice,
      'saleDate': saleDate?.toIso8601String(),
    };
  }

  factory Equity.fromMap(Map<String, dynamic> map) {
    return Equity(
      id: map['id'] ?? const Uuid().v4(),
      ticker: map['ticker'],
      companyName: map['companyName'],
      quantity: map['quantity'],
      buyPrice: map['buyPrice'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      sellPrice: map['sellPrice'],
      saleDate: map['saleDate'] != null ? DateTime.parse(map['saleDate']) : null,
    );
  }
}