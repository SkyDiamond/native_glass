import 'package:flutter/foundation.dart';

import 'render_policy.dart';

class NativeGlassConfig {
  const NativeGlassConfig({
    this.defaultRenderMode = NativeGlassRenderMode.auto,
    this.nativeFailureBehavior = NativeGlassNativeFailureBehavior.fallback,
    this.diagnosticsEnabled = kDebugMode,
    this.warnWhenTooManyPlatformViews = true,
  });

  final NativeGlassRenderMode defaultRenderMode;
  final NativeGlassNativeFailureBehavior nativeFailureBehavior;
  final bool diagnosticsEnabled;
  final bool warnWhenTooManyPlatformViews;

  NativeGlassConfig copyWith({
    NativeGlassRenderMode? defaultRenderMode,
    NativeGlassNativeFailureBehavior? nativeFailureBehavior,
    bool? diagnosticsEnabled,
    bool? warnWhenTooManyPlatformViews,
  }) {
    return NativeGlassConfig(
      defaultRenderMode: defaultRenderMode ?? this.defaultRenderMode,
      nativeFailureBehavior:
          nativeFailureBehavior ?? this.nativeFailureBehavior,
      diagnosticsEnabled: diagnosticsEnabled ?? this.diagnosticsEnabled,
      warnWhenTooManyPlatformViews:
          warnWhenTooManyPlatformViews ?? this.warnWhenTooManyPlatformViews,
    );
  }
}
