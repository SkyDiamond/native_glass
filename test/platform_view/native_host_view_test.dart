import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('does not count inactive route hosts as visible budget views', (
    tester,
  ) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: const _NativeHostRoute(),
          routes: {'/next': (_) => const SizedBox.shrink()},
        ),
      );

      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      view.onPlatformViewCreated?.call(43);

      expect(NativeGlassDiagnostics.activeNativeRendererCount, 1);
      expect(NativeGlassDiagnostics.visibleNativeRendererCount, 1);

      tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/next');
      await tester.pumpAndSettle();

      expect(NativeGlassDiagnostics.activeNativeRendererCount, 1);
      expect(NativeGlassDiagnostics.visibleNativeRendererCount, 0);
    } finally {
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });

  testWidgets('sends native visibility updates to the host view', (
    tester,
  ) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final calls = <MethodCall>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    const channel = MethodChannel('native_glass/view_44');
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });

    Future<void> pumpHost({required bool visible}) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: TickerMode(
            enabled: visible,
            child: const SizedBox(
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
        ),
      );
    }

    try {
      await pumpHost(visible: true);
      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      view.onPlatformViewCreated?.call(44);
      await tester.pump();
      calls.clear();

      await pumpHost(visible: false);
      await tester.pump();

      final setVisibleCalls = calls.where(
        (call) => call.method == 'setVisible',
      );
      expect(setVisibleCalls, hasLength(1));
      expect(setVisibleCalls.single.arguments, {'visible': false});
    } finally {
      messenger.setMockMethodCallHandler(channel, null);
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });
}

class _NativeHostRoute extends StatelessWidget {
  const _NativeHostRoute();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
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
    );
  }
}
