import 'availability.dart';
import 'config.dart';

enum NativeGlassRenderMode { auto, native, flutter }

enum NativeGlassNativeFailureBehavior { fallback, assertInDebug, throwInDebug }

enum NativeGlassFallbackReason {
  none,
  unsupportedPlatform,
  nativeRendererUnavailable,
  liquidGlassUnavailable,
  componentNotNativeCandidate,
  componentNativeUnsupported,
  platformViewBudgetExceeded,
  invalidConfiguration,
  nativeFailureBehaviorFallback,
}

enum NativeGlassRenderer { nativeRenderer, flutterFallback }

enum NativeGlassComponentRole {
  systemSurface,
  nativeLeafControl,
  leafControl,
  decorativeSurface,
}

class NativeGlassRenderDecision {
  const NativeGlassRenderDecision({
    required this.renderer,
    required this.requestedMode,
    required this.fallbackReason,
    required this.supportsNativeRenderer,
    required this.supportsLiquidGlass,
    required this.shouldAssertInDebug,
    required this.shouldThrowInDebug,
    required this.diagnosticMessage,
  });

  final NativeGlassRenderer renderer;
  final NativeGlassRenderMode requestedMode;
  final NativeGlassFallbackReason fallbackReason;
  final bool supportsNativeRenderer;
  final bool supportsLiquidGlass;
  final bool shouldAssertInDebug;
  final bool shouldThrowInDebug;
  final String diagnosticMessage;
}

void enforceNativeGlassFailureBehavior(NativeGlassRenderDecision decision) {
  assert(() {
    if (decision.shouldThrowInDebug) {
      throw StateError(decision.diagnosticMessage);
    }
    if (decision.shouldAssertInDebug) {
      throw AssertionError(decision.diagnosticMessage);
    }
    return true;
  }());
}

NativeGlassRenderDecision resolveNativeGlassRenderPolicy({
  required NativeGlassComponentRole component,
  required NativeGlassRenderMode? requestedMode,
  required NativeGlassConfig config,
  required NativeGlassAvailability availability,
}) {
  final mode = requestedMode ?? config.defaultRenderMode;

  if (mode == NativeGlassRenderMode.flutter) {
    return _fallbackDecision(
      mode: mode,
      availability: availability,
      reason: NativeGlassFallbackReason.none,
      config: config,
      message: 'Flutter Fallback requested.',
      nativeFailure: false,
    );
  }

  final nativeCandidate =
      component == NativeGlassComponentRole.systemSurface ||
      component == NativeGlassComponentRole.nativeLeafControl;
  if (!nativeCandidate) {
    final reason = mode == NativeGlassRenderMode.native
        ? NativeGlassFallbackReason.componentNativeUnsupported
        : NativeGlassFallbackReason.componentNotNativeCandidate;
    return _fallbackDecision(
      mode: mode,
      availability: availability,
      reason: reason,
      config: config,
      message: 'Component policy selected Flutter Fallback.',
      nativeFailure: mode == NativeGlassRenderMode.native,
    );
  }

  if (!availability.supportsNativeRenderer) {
    return _fallbackDecision(
      mode: mode,
      availability: availability,
      reason:
          availability.fallbackReason ??
          (availability.isIOS
              ? NativeGlassFallbackReason.nativeRendererUnavailable
              : NativeGlassFallbackReason.unsupportedPlatform),
      config: config,
      message: 'Native Renderer is unavailable.',
      nativeFailure: mode == NativeGlassRenderMode.native,
    );
  }

  return NativeGlassRenderDecision(
    renderer: NativeGlassRenderer.nativeRenderer,
    requestedMode: mode,
    fallbackReason: NativeGlassFallbackReason.none,
    supportsNativeRenderer: availability.supportsNativeRenderer,
    supportsLiquidGlass: availability.supportsLiquidGlass,
    shouldAssertInDebug: false,
    shouldThrowInDebug: false,
    diagnosticMessage: availability.supportsLiquidGlass
        ? 'Native Renderer selected with Liquid Glass support.'
        : 'Native Renderer selected with standard UIKit appearance.',
  );
}

NativeGlassRenderDecision _fallbackDecision({
  required NativeGlassRenderMode mode,
  required NativeGlassAvailability availability,
  required NativeGlassFallbackReason reason,
  required NativeGlassConfig config,
  required String message,
  required bool nativeFailure,
}) {
  return NativeGlassRenderDecision(
    renderer: NativeGlassRenderer.flutterFallback,
    requestedMode: mode,
    fallbackReason: reason,
    supportsNativeRenderer: availability.supportsNativeRenderer,
    supportsLiquidGlass: availability.supportsLiquidGlass,
    shouldAssertInDebug:
        nativeFailure &&
        config.nativeFailureBehavior ==
            NativeGlassNativeFailureBehavior.assertInDebug,
    shouldThrowInDebug:
        nativeFailure &&
        config.nativeFailureBehavior ==
            NativeGlassNativeFailureBehavior.throwInDebug,
    diagnosticMessage: message,
  );
}
