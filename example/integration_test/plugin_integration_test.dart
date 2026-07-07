import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('availability check returns a safe result', (tester) async {
    final availability = await NativeGlassAvailability.refresh();

    expect(availability.supportsNativeRenderer, isA<bool>());
    expect(availability.supportsLiquidGlass, isA<bool>());
  });
}
