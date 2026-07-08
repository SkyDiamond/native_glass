import 'dart:developer' as developer;

import '../adaptive/render_policy.dart';
import 'diagnostic_event.dart';

typedef NativeGlassDiagnosticListener =
    void Function(NativeGlassDiagnosticEvent event);

class NativeGlassDiagnostics {
  NativeGlassDiagnostics._();

  static const platformViewBudgetWarningThreshold = 6;

  static NativeGlassDiagnosticListener? listener;
  static int _activeNativeRendererCount = 0;
  static int _visibleNativeRendererCount = 0;
  static int _propUpdateCount = 0;
  static int _structuralRebuildCount = 0;

  static int get activeNativeRendererCount => _activeNativeRendererCount;

  static int get visibleNativeRendererCount => _visibleNativeRendererCount;

  static int get propUpdateCount => _propUpdateCount;

  static int get structuralRebuildCount => _structuralRebuildCount;

  static void emit(NativeGlassDiagnosticEvent event) {
    developer.log(event.message, name: 'NativeGlass');
    listener?.call(event);
  }

  static NativeGlassRendererRegistration registerNativeRenderer({
    bool visible = true,
    bool warnWhenTooManyPlatformViews = true,
  }) {
    _activeNativeRendererCount += 1;
    if (visible) _visibleNativeRendererCount += 1;
    _emitPlatformViewBudgetWarningIfNeeded(warnWhenTooManyPlatformViews);
    return NativeGlassRendererRegistration._(visible: visible);
  }

  static void recordPropUpdate() {
    _propUpdateCount += 1;
  }

  static void recordStructuralRebuild() {
    _structuralRebuildCount += 1;
  }

  static void resetForTesting() {
    listener = null;
    _activeNativeRendererCount = 0;
    _visibleNativeRendererCount = 0;
    _propUpdateCount = 0;
    _structuralRebuildCount = 0;
  }

  static void _setVisible(
    NativeGlassRendererRegistration registration,
    bool visible,
    bool warnWhenTooManyPlatformViews,
  ) {
    if (registration._disposed || registration._visible == visible) return;
    registration._visible = visible;
    _visibleNativeRendererCount += visible ? 1 : -1;
    _emitPlatformViewBudgetWarningIfNeeded(warnWhenTooManyPlatformViews);
  }

  static void _dispose(NativeGlassRendererRegistration registration) {
    if (registration._disposed) return;
    registration._disposed = true;
    _activeNativeRendererCount -= 1;
    if (registration._visible) {
      registration._visible = false;
      _visibleNativeRendererCount -= 1;
    }
  }

  static void _emitPlatformViewBudgetWarningIfNeeded(bool enabled) {
    if (!enabled) return;
    if (_visibleNativeRendererCount < platformViewBudgetWarningThreshold) {
      return;
    }

    emit(
      NativeGlassDiagnosticEvent(
        message:
            'PlatformView Budget warning: '
            '$_visibleNativeRendererCount visible Native Renderer views.',
        fallbackReason: NativeGlassFallbackReason.platformViewBudgetExceeded,
        activeNativeRendererCount: _activeNativeRendererCount,
        visibleNativeRendererCount: _visibleNativeRendererCount,
        propUpdateCount: _propUpdateCount,
        structuralRebuildCount: _structuralRebuildCount,
      ),
    );
  }
}

class NativeGlassRendererRegistration {
  NativeGlassRendererRegistration._({required this._visible});

  bool _visible;
  bool _disposed = false;

  void setVisible(bool visible, {bool warnWhenTooManyPlatformViews = true}) {
    NativeGlassDiagnostics._setVisible(
      this,
      visible,
      warnWhenTooManyPlatformViews,
    );
  }

  void dispose() {
    NativeGlassDiagnostics._dispose(this);
  }
}
