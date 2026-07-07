import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass_example/main.dart';

void main() {
  testWidgets('shows the native_glass showcase', (tester) async {
    await tester.pumpWidget(const NativeGlassExampleApp());

    expect(find.text('native_glass'), findsOneWidget);
    expect(find.text('Flutter Fallback container'), findsOneWidget);
  });
}
