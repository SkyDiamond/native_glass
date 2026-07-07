import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/adaptive/availability.dart';
import 'package:native_glass/src/adaptive/config.dart';
import 'package:native_glass/src/adaptive/render_policy.dart';

void main() {
  test(
    'auto uses native renderer for system surfaces when native is available',
    () {
      final decision = resolveNativeGlassRenderPolicy(
        component: NativeGlassComponentRole.systemSurface,
        requestedMode: null,
        config: const NativeGlassConfig(),
        availability: const NativeGlassAvailability(
          isIOS: true,
          supportsNativeRenderer: true,
          supportsLiquidGlass: false,
        ),
      );

      expect(decision.renderer, NativeGlassRenderer.nativeRenderer);
      expect(decision.fallbackReason, NativeGlassFallbackReason.none);
    },
  );

  test('auto uses Flutter fallback for decorative surfaces', () {
    final decision = resolveNativeGlassRenderPolicy(
      component: NativeGlassComponentRole.decorativeSurface,
      requestedMode: null,
      config: const NativeGlassConfig(),
      availability: const NativeGlassAvailability(
        isIOS: true,
        supportsNativeRenderer: true,
        supportsLiquidGlass: true,
      ),
    );

    expect(decision.renderer, NativeGlassRenderer.flutterFallback);
    expect(
      decision.fallbackReason,
      NativeGlassFallbackReason.componentNotNativeCandidate,
    );
  });

  test(
    'native requests fall back safely when native renderer is unavailable',
    () {
      final decision = resolveNativeGlassRenderPolicy(
        component: NativeGlassComponentRole.systemSurface,
        requestedMode: NativeGlassRenderMode.native,
        config: const NativeGlassConfig(),
        availability: const NativeGlassAvailability(
          isIOS: false,
          supportsNativeRenderer: false,
          supportsLiquidGlass: false,
          fallbackReason: NativeGlassFallbackReason.unsupportedPlatform,
        ),
      );

      expect(decision.renderer, NativeGlassRenderer.flutterFallback);
      expect(
        decision.fallbackReason,
        NativeGlassFallbackReason.unsupportedPlatform,
      );
    },
  );

  test(
    'throwInDebug marks debug-only throws without changing release fallback',
    () {
      final decision = resolveNativeGlassRenderPolicy(
        component: NativeGlassComponentRole.systemSurface,
        requestedMode: NativeGlassRenderMode.native,
        config: const NativeGlassConfig(
          nativeFailureBehavior: NativeGlassNativeFailureBehavior.throwInDebug,
        ),
        availability: const NativeGlassAvailability(
          isIOS: false,
          supportsNativeRenderer: false,
          supportsLiquidGlass: false,
        ),
      );

      expect(decision.renderer, NativeGlassRenderer.flutterFallback);
      expect(decision.shouldThrowInDebug, isTrue);
    },
  );
}
