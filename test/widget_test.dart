import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finance_universe/main.dart';
import 'package:finance_universe/models/transaction.dart';
import 'package:finance_universe/models/equity.dart';
import 'package:finance_universe/models/derivative.dart';
import 'package:finance_universe/models/goal.dart';
import 'dart:io';

void main() {
  group('Finance Universe App Tests', () {
    setUpAll(() async {
      final path = Directory.current.path;
      Hive.init('$path/test/hive_testing_path');

      Hive.registerAdapter(TransactionAdapter());
      Hive.registerAdapter(TransactionTypeAdapter());
      Hive.registerAdapter(EquityAdapter());
      Hive.registerAdapter(DerivativeTradeAdapter());
      Hive.registerAdapter(TradeTypeAdapter());
      Hive.registerAdapter(GoalAdapter());

      await Hive.openBox<Transaction>('transactions');
      await Hive.openBox<Equity>('equities');
      await Hive.openBox<DerivativeTrade>('derivatives');
      await Hive.openBox<Goal>('goals');
    });

    tearDownAll(() async {
      await Hive.close();
    });

    testWidgets('App starts and shows Dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(const FinanceUniverseApp());

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Net Cash Flow'), findsOneWidget);
    });
  });
}