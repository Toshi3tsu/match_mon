// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:match_mon/main.dart';

void main() {
  setUpAll(() async {
    // 日本語ロケールの日付フォーマットを初期化
    await initializeDateFormatting('ja_JP', null);
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app with ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that the app has launched (check for app title or any widget)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
