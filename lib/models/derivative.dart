import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'derivative.g.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'instrument': instrument,
      'tradeType': tradeType.index,
      'buyDate': buyDate.toIso8601String(),
      'saleDate': saleDate?.toIso8601String(),
      'netPandL': netPandL,
      'strategy': strategy,
      'learnings': learnings,
    };
  }

  factory DerivativeTrade.fromMap(Map<String, dynamic> map) {
    return DerivativeTrade(
      id: map['id'] ?? const Uuid().v4(),
      instrument: map['instrument'],
      tradeType: TradeType.values[map['tradeType']],
      buyDate: DateTime.parse(map['buyDate']),
      saleDate: map['saleDate'] != null ? DateTime.parse(map['saleDate']) : null,
      netPandL: map['netPandL'],
      strategy: map['strategy'],
      learnings: map['learnings'],
    );
  }
}