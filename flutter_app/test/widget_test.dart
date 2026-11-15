import 'package:flutter_test/flutter_test.dart';
import 'package:nmms_ponsri_native/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NmmsApp());
    expect(find.byType(NmmsApp), findsOneWidget);
  });
}
