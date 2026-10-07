import 'package:flutter_test/flutter_test.dart';
import 'package:helpi/core/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppState initial state test', () {
    final state = AppState();
    expect(state.loading, true);
    expect(state.authenticated, false);
    expect(state.demoCases, isNotEmpty);
  });

  test('AppState demo cases category and structure test', () {
    final state = AppState();
    final cases = state.demoCases;
    expect(cases.length, greaterThanOrEqualTo(3));
    for (final c in cases) {
      expect(c['id'], isNotNull);
      expect(c['title'], isNotNull);
      expect(c['category'], isNotNull);
      expect(c['goalMinor'], greaterThan(0));
    }
  });
}
