import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  tearDown(() {
    NativeGlassAvailability.resetForTesting();
    NativeGlassDiagnostics.resetForTesting();
  });

  testWidgets('calls onPressed when enabled', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: NativeGlassButton(
          onPressed: () => taps += 1,
          child: const Text('Continue'),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));

    expect(taps, 1);
  });

  testWidgets('does not call onPressed when disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NativeGlassButton(onPressed: null, child: Text('Continue')),
      ),
    );

    await tester.tap(find.text('Continue'));

    expect(tester.takeException(), isNull);
  });

  testWidgets('uses native renderer for serializable text buttons', (
    tester,
  ) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    NativeGlassAvailability.debugCheckOverride = () async {
      return const NativeGlassAvailability(
        isIOS: true,
        supportsNativeRenderer: true,
        supportsLiquidGlass: true,
      );
    };

    try {
      await tester.pumpWidget(
        MaterialApp(
          home: NativeGlassButton(
            onPressed: () {},
            renderMode: NativeGlassRenderMode.native,
            child: const Text('Continue'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(UiKitView), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });

  testWidgets('keeps arbitrary Flutter children on fallback rendering', (
    tester,
  ) async {
    NativeGlassAvailability.debugCheckOverride = () async {
      return const NativeGlassAvailability(
        isIOS: true,
        supportsNativeRenderer: true,
        supportsLiquidGlass: true,
      );
    };

    await tester.pumpWidget(
      MaterialApp(
        home: NativeGlassButton(
          onPressed: () {},
          renderMode: NativeGlassRenderMode.native,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.add), Text('Add')],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(UiKitView), findsNothing);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('enforces debug throws for explicit native arbitrary children', (
    tester,
  ) async {
    NativeGlassAvailability.debugCheckOverride = () async {
      return const NativeGlassAvailability(
        isIOS: true,
        supportsNativeRenderer: true,
        supportsLiquidGlass: true,
      );
    };

    await tester.pumpWidget(
      NativeGlassTheme(
        data: const NativeGlassThemeData(
          config: NativeGlassConfig(
            nativeFailureBehavior:
                NativeGlassNativeFailureBehavior.throwInDebug,
          ),
        ),
        child: MaterialApp(
          home: NativeGlassButton(
            onPressed: () {},
            renderMode: NativeGlassRenderMode.native,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.add), Text('Add')],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isA<StateError>());
  });

  testWidgets('does not emit budget warnings when diagnostics are disabled', (
    tester,
  ) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final events = <NativeGlassDiagnosticEvent>[];
    NativeGlassDiagnostics.listener = events.add;
    NativeGlassAvailability.debugCheckOverride = () async {
      return const NativeGlassAvailability(
        isIOS: true,
        supportsNativeRenderer: true,
        supportsLiquidGlass: true,
      );
    };

    try {
      await tester.pumpWidget(
        NativeGlassTheme(
          data: const NativeGlassThemeData(
            config: NativeGlassConfig(diagnosticsEnabled: false),
          ),
          child: MaterialApp(
            home: Column(
              children: List.generate(
                6,
                (index) => NativeGlassButton(
                  onPressed: () {},
                  renderMode: NativeGlassRenderMode.native,
                  child: Text('Button $index'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final views = tester.widgetList<UiKitView>(find.byType(UiKitView));
      var viewId = 0;
      for (final view in views) {
        view.onPlatformViewCreated?.call(viewId);
        viewId += 1;
      }

      expect(events, isEmpty);
    } finally {
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });
}
