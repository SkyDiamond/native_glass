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
          bottomNavigationBar: NativeGlassTabBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              NativeGlassDestination(
                label: 'Home',
                icon: NativeGlassIcon.flutterIcon(Icons.home_outlined),
              ),
              NativeGlassDestination(
                label: 'Search',
                icon: NativeGlassIcon.flutterIcon(Icons.search),
              ),
            ],
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
    expect(events.last.message, contains('NativeGlassTabBar'));
  });
}
