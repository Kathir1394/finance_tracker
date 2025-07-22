// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/equity.dart';
import 'package:finance_tracker/models/derivative.dart';
import 'package:finance_tracker/models/goal.dart';
import 'dart:io'; // Needed for Directory

void main() {
  // This group will run tests related to the main app widget
  group('Finance Tracker App Tests', () {
    // This function runs before each test in the group
    setUpAll(() async {
      // For testing, Hive needs a path to store its files.
      // We create a temporary directory for this.
      final path = Directory.current.path;
      Hive.init('$path/test/hive_testing_path');

      // Register all adapters, just like in main.dart
      Hive.registerAdapter(TransactionAdapter());
      Hive.registerAdapter(TransactionTypeAdapter());
      Hive.registerAdapter(EquityAdapter());
      Hive.registerAdapter(DerivativeTradeAdapter());
      Hive.registerAdapter(TradeTypeAdapter());
      Hive.registerAdapter(GoalAdapter());

      // Open all boxes needed by the widgets before the test runs
      await Hive.openBox<Transaction>('transactions');
      await Hive.openBox<Equity>('equities');
      await Hive.openBox<DerivativeTrade>('derivatives');
      await Hive.openBox<Goal>('goals');
    });

    // This function runs after all tests in the group are finished
    tearDownAll(() async {
      await Hive.close();
    });

    testWidgets('App starts and shows Dashboard', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const FinanceTrackerApp());

      // FIX: Verify that the Dashboard screen is visible by checking for its title specifically within the AppBar.
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Dashboard')), findsOneWidget);

      // Verify that one of the stat cards is present.
      expect(find.text('Net Flow'), findsOneWidget);
    });
  });
}