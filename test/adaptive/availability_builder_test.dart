import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  tearDown(NativeGlassAvailability.resetForTesting);

  testWidgets('builds with checked availability', (tester) async {
    NativeGlassAvailability.debugCheckOverride = () async {
      return const NativeGlassAvailability(
        isIOS: true,
        supportsNativeRenderer: true,
        supportsLiquidGlass: true,
      );
    };

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NativeGlassAvailabilityBuilder(
          builder: (context, availability) {
            return Text('Liquid Glass: ${availability.supportsLiquidGlass}');
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Liquid Glass: true'), findsOneWidget);
  });
}
