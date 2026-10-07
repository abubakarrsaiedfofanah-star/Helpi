import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:helpi/core/app_state.dart';
import 'package:helpi/main.dart';

void main() {
  testWidgets('HelpiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const HelpiApp(),
      ),
    );
    expect(find.byType(HelpiApp), findsOneWidget);
  });
}
