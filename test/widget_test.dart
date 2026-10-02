import 'package:flutter_test/flutter_test.dart';
import 'package:homeserve_app/main.dart';

void main() {
  testWidgets('HomeServeApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeServeApp());
  });
}
