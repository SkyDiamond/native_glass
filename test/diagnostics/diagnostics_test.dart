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
}
