import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  tearDown(NativeGlassDiagnostics.resetForTesting);

  test('emits diagnostic events to the configured listener', () {
    final events = <NativeGlassDiagnosticEvent>[];
    NativeGlassDiagnostics.listener = events.add;

    const event = NativeGlassDiagnosticEvent(
      message: 'Fallback selected',
      fallbackReason: NativeGlassFallbackReason.unsupportedPlatform,
    );
    NativeGlassDiagnostics.emit(event);

    expect(events, [event]);
  });

  test('tracks active and visible native renderer counts', () {
    final registration = NativeGlassDiagnostics.registerNativeRenderer(
      visible: true,
    );

    expect(NativeGlassDiagnostics.activeNativeRendererCount, 1);
    expect(NativeGlassDiagnostics.visibleNativeRendererCount, 1);

    registration.setVisible(false);

    expect(NativeGlassDiagnostics.activeNativeRendererCount, 1);
    expect(NativeGlassDiagnostics.visibleNativeRendererCount, 0);

    registration.dispose();

    expect(NativeGlassDiagnostics.activeNativeRendererCount, 0);
    expect(NativeGlassDiagnostics.visibleNativeRendererCount, 0);
  });

  test('tracks prop updates and structural rebuilds', () {
    NativeGlassDiagnostics.recordPropUpdate();
    NativeGlassDiagnostics.recordPropUpdate();
    NativeGlassDiagnostics.recordStructuralRebuild();

    expect(NativeGlassDiagnostics.propUpdateCount, 2);
    expect(NativeGlassDiagnostics.structuralRebuildCount, 1);
  });

  test('emits a PlatformView Budget warning at six visible renderers', () {
    final events = <NativeGlassDiagnosticEvent>[];
    NativeGlassDiagnostics.listener = events.add;

    for (var i = 0; i < 6; i += 1) {
      NativeGlassDiagnostics.registerNativeRenderer();
    }

    expect(events, isNotEmpty);
    expect(
      events.last.fallbackReason,
      NativeGlassFallbackReason.platformViewBudgetExceeded,
    );
    expect(events.last.visibleNativeRendererCount, 6);
    expect(events.last.activeNativeRendererCount, 6);
  });

  test('can suppress PlatformView Budget warnings', () {
    final events = <NativeGlassDiagnosticEvent>[];
    NativeGlassDiagnostics.listener = events.add;

    for (var i = 0; i < 6; i += 1) {
      NativeGlassDiagnostics.registerNativeRenderer(
        warnWhenTooManyPlatformViews: false,
      );
    }

    expect(events, isEmpty);
    expect(NativeGlassDiagnostics.visibleNativeRendererCount, 6);
  });
}
