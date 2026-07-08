import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/adaptive/render_policy.dart';
import 'package:native_glass/src/diagnostics/diagnostics.dart';
import 'package:native_glass/src/platform_view/native_host_view.dart';

void main() {
  tearDown(() {
    NativeGlassDiagnostics.resetForTesting();
  });

  testWidgets('forwards pointer sequences eagerly to UIKit views', (
    tester,
  ) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 100,
            height: 80,
            child: NativeGlassNativeHostView(
              creationParams: {
                'component': 'placeholder',
                'props': <String, Object?>{},
              },
              props: <String, Object?>{},
            ),
          ),
        ),
      );

      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      final recognizers = view.gestureRecognizers;

      expect(recognizers, isNotNull);
      expect(recognizers, hasLength(1));
      expect(recognizers!.single.constructor(), isA<EagerGestureRecognizer>());
    } finally {
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });

  testWidgets('does not count ticker-disabled hosts as visible budget views', (
    tester,
  ) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final events = <NativeGlassFallbackReason>[];
    NativeGlassDiagnostics.listener = (event) {
      final reason = event.fallbackReason;
      if (reason != null) events.add(reason);
    };

    try {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              for (var index = 0; index < 5; index += 1)
                const TickerMode(
                  enabled: false,
                  child: SizedBox(
                    width: 100,
                    height: 20,
                    child: NativeGlassNativeHostView(
                      creationParams: {
                        'schema_version': 1,
                        'component': 'placeholder',
                        'props': <String, Object?>{},
                      },
                      props: <String, Object?>{},
                    ),
                  ),
                ),
              const SizedBox(
                width: 100,
                height: 20,
                child: NativeGlassNativeHostView(
                  creationParams: {
                    'schema_version': 1,
                    'component': 'placeholder',
                    'props': <String, Object?>{},
                  },
                  props: <String, Object?>{},
                ),
              ),
            ],
          ),
        ),
      );

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      var viewId = 0;
      for (final view in views) {
        view.onPlatformViewCreated?.call(viewId);
        viewId += 1;
      }

      expect(NativeGlassDiagnostics.activeNativeRendererCount, 6);
      expect(NativeGlassDiagnostics.visibleNativeRendererCount, 1);
      expect(
        events,
        isNot(contains(NativeGlassFallbackReason.platformViewBudgetExceeded)),
      );
    } finally {
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });

  testWidgets('notifies the native host when the Dart handler is ready', (
    tester,
  ) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final calls = <String>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    const channel = MethodChannel('native_glass/view_42');
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return null;
    });

    try {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 100,
            height: 80,
            child: NativeGlassNativeHostView(
              creationParams: {
                'schema_version': 1,
                'component': 'placeholder',
                'props': <String, Object?>{},
              },
              props: <String, Object?>{},
            ),
          ),
        ),
      );

      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      view.onPlatformViewCreated?.call(42);
      await tester.pump();

      expect(calls, contains('ready'));
    } finally {
      messenger.setMockMethodCallHandler(channel, null);
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });
}
