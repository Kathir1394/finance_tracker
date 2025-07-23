import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late double amount;
  @HiveField(2)
  late String description;
  @HiveField(3)
  late String category;
  @HiveField(4)
  late DateTime date;
  @HiveField(5)
  late TransactionType type;
  @HiveField(6)
  late String paymentMethod;
  @HiveField(7)
  String? store;
  @HiveField(8)
  String? notes;
  @HiveField(9)
  bool isRecurring;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.type,
    required this.paymentMethod,
    this.store,
    this.notes,
    this.isRecurring = false,
  });

  // Method to convert instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'type': type.index,
      'paymentMethod': paymentMethod,
      'store': store,
      'notes': notes,
      'isRecurring': isRecurring,
    };
  }

  // Factory constructor to create instance from a map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? const Uuid().v4(),
      amount: map['amount'],
      description: map['description'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values[map['type']],
      paymentMethod: map['paymentMethod'],
      store: map['store'],
      notes: map['notes'],
      isRecurring: map['isRecurring'] ?? false,
    );
  }
}