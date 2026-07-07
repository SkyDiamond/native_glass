import 'dart:developer' as developer;

import 'diagnostic_event.dart';

typedef NativeGlassDiagnosticListener =
    void Function(NativeGlassDiagnosticEvent event);

class NativeGlassDiagnostics {
  NativeGlassDiagnostics._();

  static NativeGlassDiagnosticListener? listener;
  static int _activeNativeRendererCount = 0;
  static int _visibleNativeRendererCount = 0;

  static int get activeNativeRendererCount => _activeNativeRendererCount;

  static int get visibleNativeRendererCount => _visibleNativeRendererCount;

  static void emit(NativeGlassDiagnosticEvent event) {
    developer.log(event.message, name: 'NativeGlass');
    listener?.call(event);
  }

  static NativeGlassRendererRegistration registerNativeRenderer({
    bool visible = true,
  }) {
    _activeNativeRendererCount += 1;
    if (visible) _visibleNativeRendererCount += 1;
    return NativeGlassRendererRegistration._(visible: visible);
  }

  static void resetForTesting() {
    listener = null;
    _activeNativeRendererCount = 0;
    _visibleNativeRendererCount = 0;
  }

  static void _setVisible(
    NativeGlassRendererRegistration registration,
    bool visible,
  ) {
    if (registration._disposed || registration._visible == visible) return;
    registration._visible = visible;
    _visibleNativeRendererCount += visible ? 1 : -1;
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
}

class NativeGlassRendererRegistration {
  NativeGlassRendererRegistration._({required this._visible});

  bool _visible;
  bool _disposed = false;

  void setVisible(bool visible) {
    NativeGlassDiagnostics._setVisible(this, visible);
  }

  void dispose() {
    NativeGlassDiagnostics._dispose(this);
  }
}
