import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'render_policy.dart';

typedef NativeGlassAvailabilityChecker =
    Future<NativeGlassAvailability> Function();

class NativeGlassIOSVersion {
  const NativeGlassIOSVersion({
    required this.major,
    required this.minor,
    required this.patch,
  });

  factory NativeGlassIOSVersion.parse(String value) {
    final parts = value.split('.');
    int readPart(int index) {
      if (index >= parts.length) return 0;
      return int.tryParse(parts[index]) ?? 0;
    }

    return NativeGlassIOSVersion(
      major: readPart(0),
      minor: readPart(1),
      patch: readPart(2),
    );
  }

  final int major;
  final int minor;
  final int patch;

  @override
  String toString() => '$major.$minor.$patch';
}

class NativeGlassAvailability {
  const NativeGlassAvailability({
    required this.isIOS,
    this.iosVersion,
    required this.supportsNativeRenderer,
    required this.supportsLiquidGlass,
    this.fallbackReason,
  });

  static const MethodChannel _channel = MethodChannel('native_glass');

  static NativeGlassAvailability? _cached;

  @visibleForTesting
  static NativeGlassAvailabilityChecker? debugCheckOverride;

  final bool isIOS;
  final NativeGlassIOSVersion? iosVersion;
  final bool supportsNativeRenderer;
  final bool supportsLiquidGlass;
  final NativeGlassFallbackReason? fallbackReason;

  static Future<NativeGlassAvailability> check() async {
    return _cached ??= await _load();
  }

  static Future<NativeGlassAvailability> refresh() async {
    return _cached = await _load();
  }

  @visibleForTesting
  static void resetForTesting() {
    _cached = null;
    debugCheckOverride = null;
  }

  static Future<NativeGlassAvailability> _load() async {
    try {
      final override = debugCheckOverride;
      if (override != null) return await override();
      return await _checkPlatform();
    } catch (_) {
      return const NativeGlassAvailability(
        isIOS: false,
        supportsNativeRenderer: false,
        supportsLiquidGlass: false,
        fallbackReason: NativeGlassFallbackReason.nativeRendererUnavailable,
      );
    }
  }

  static Future<NativeGlassAvailability> _checkPlatform() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return const NativeGlassAvailability(
        isIOS: false,
        supportsNativeRenderer: false,
        supportsLiquidGlass: false,
        fallbackReason: NativeGlassFallbackReason.unsupportedPlatform,
      );
    }

    final payload = await _channel.invokeMapMethod<String, Object?>(
      'getAvailability',
    );
    final iosVersionString = payload?['ios_version'] as String?;

    return NativeGlassAvailability(
      isIOS: true,
      iosVersion: iosVersionString == null
          ? null
          : NativeGlassIOSVersion.parse(iosVersionString),
      supportsNativeRenderer:
          payload?['supports_native_renderer'] as bool? ?? false,
      supportsLiquidGlass: payload?['supports_liquid_glass'] as bool? ?? false,
      fallbackReason: payload?['supports_native_renderer'] == true
          ? null
          : NativeGlassFallbackReason.nativeRendererUnavailable,
    );
  }
}
