import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/adaptive/availability.dart';
import 'package:native_glass/src/adaptive/render_policy.dart';

void main() {
  tearDown(NativeGlassAvailability.resetForTesting);

  test('caches availability checks package-wide', () async {
    var calls = 0;
    NativeGlassAvailability.debugCheckOverride = () async {
      calls += 1;
      return const NativeGlassAvailability(
        isIOS: true,
        iosVersion: NativeGlassIOSVersion(major: 26, minor: 0, patch: 0),
        supportsNativeRenderer: true,
        supportsLiquidGlass: true,
      );
    };

    final first = await NativeGlassAvailability.check();
    final second = await NativeGlassAvailability.check();

    expect(first, same(second));
    expect(calls, 1);
  });

  test('refresh replaces the cached availability value', () async {
    var supportsLiquidGlass = false;
    NativeGlassAvailability.debugCheckOverride = () async {
      return NativeGlassAvailability(
        isIOS: true,
        supportsNativeRenderer: true,
        supportsLiquidGlass: supportsLiquidGlass,
      );
    };

    final first = await NativeGlassAvailability.check();
    supportsLiquidGlass = true;
    final second = await NativeGlassAvailability.refresh();

    expect(first.supportsLiquidGlass, isFalse);
    expect(second.supportsLiquidGlass, isTrue);
  });

  test(
    'normalizes native channel failures into unavailable fallback',
    () async {
      NativeGlassAvailability.debugCheckOverride = () async {
        throw StateError('channel failed');
      };

      final availability = await NativeGlassAvailability.refresh();

      expect(availability.isIOS, isFalse);
      expect(availability.supportsNativeRenderer, isFalse);
      expect(availability.supportsLiquidGlass, isFalse);
      expect(
        availability.fallbackReason,
        NativeGlassFallbackReason.nativeRendererUnavailable,
      );
    },
  );
}
