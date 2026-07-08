import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  tearDown(() {
    NativeGlassAvailability.resetForTesting();
    NativeGlassDiagnostics.resetForTesting();
  });

  testWidgets('emits a diagnostic event for fallback render decisions', (
    tester,
  ) async {
    NativeGlassAvailability.debugCheckOverride = () async {
      return const NativeGlassAvailability(
        isIOS: false,
        supportsNativeRenderer: false,
        supportsLiquidGlass: false,
        fallbackReason: NativeGlassFallbackReason.unsupportedPlatform,
      );
    };
    final events = <NativeGlassDiagnosticEvent>[];
    NativeGlassDiagnostics.listener = events.add;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: NativeGlassNavigationBar(
            title: 'Portfolio',
            onActionSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(events, isNotEmpty);
    expect(
      events.last.fallbackReason,
      NativeGlassFallbackReason.unsupportedPlatform,
    );
    expect(events.last.message, contains('NativeGlassNavigationBar'));
  });

  testWidgets('does not emit diagnostics synchronously during build', (
    tester,
  ) async {
    NativeGlassAvailability.debugCheckOverride = () async {
      return const NativeGlassAvailability(
        isIOS: true,
        supportsNativeRenderer: true,
        supportsLiquidGlass: true,
      );
    };

    await tester.pumpWidget(const _DiagnosticsSetStateHarness());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Events:'), findsOneWidget);
  });
}

class _DiagnosticsSetStateHarness extends StatefulWidget {
  const _DiagnosticsSetStateHarness();

  @override
  State<_DiagnosticsSetStateHarness> createState() =>
      _DiagnosticsSetStateHarnessState();
}

class _DiagnosticsSetStateHarnessState
    extends State<_DiagnosticsSetStateHarness> {
  var _eventCount = 0;

  @override
  void initState() {
    super.initState();
    NativeGlassDiagnostics.listener = (_) {
      setState(() => _eventCount += 1);
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: NativeGlassNavigationBar(
          title: 'Portfolio',
          onActionSelected: (_) {},
        ),
        body: Text('Events: $_eventCount'),
      ),
    );
  }
}
