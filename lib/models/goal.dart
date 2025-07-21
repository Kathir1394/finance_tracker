import 'package:hive/hive.dart';

part 'goal.g.dart'; // This file will be generated

@HiveType(typeId: 5)
class Goal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double targetAmount;

  @HiveField(3)
  late double currentAmount;

  @HiveField(4)
  late DateTime targetDate;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });
}