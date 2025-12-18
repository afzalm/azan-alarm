import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_azan_alarm/main.dart';

void main() {
  testWidgets('AzanAlarmApp builds without errors', (WidgetTester tester) async {
    // Build the app wrapped in ProviderScope required by Riverpod
    await tester.pumpWidget(const ProviderScope(child: AzanAlarmApp()));

    // Let router perform initial build
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // Verify that a MaterialApp is present (MaterialApp.router still has type MaterialApp)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
