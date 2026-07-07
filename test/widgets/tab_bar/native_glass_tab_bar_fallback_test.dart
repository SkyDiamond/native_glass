import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  testWidgets('calls onDestinationSelected when tapping selected destination', (
    tester,
  ) async {
    final selections = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NativeGlassTabBar(
            selectedIndex: 0,
            onDestinationSelected: selections.add,
            destinations: const [
              NativeGlassDestination(
                label: 'Home',
                icon: NativeGlassIcon.flutterIcon(Icons.home_outlined),
                selectedIcon: NativeGlassIcon.flutterIcon(Icons.home),
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

    await tester.tap(find.text('Home'));

    expect(selections, [0]);
  });

  testWidgets('clamps out-of-range selectedIndex for fallback rendering', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NativeGlassTabBar(
            selectedIndex: 99,
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

    expect(tester.takeException(), isNull);
  });
}
