import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:helpi/core/app_state.dart';
import 'package:helpi/features/emergency/emergency_screen.dart';

void main() {
  testWidgets('EmergencyScreen smoke test with semantics', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          home: EmergencyScreen(),
        ),
      ),
    );

    expect(find.text('Emergency Access'), findsOneWidget);
    expect(find.text('I NEED URGENT HELP'), findsOneWidget);
    expect(find.text('Medical'), findsOneWidget);
  });
}
