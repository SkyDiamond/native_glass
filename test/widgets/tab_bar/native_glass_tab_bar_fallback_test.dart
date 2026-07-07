import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  test('defaults to an explicit 80px height', () {
    final tabBar = NativeGlassTabBar(
      selectedIndex: 0,
      onDestinationSelected: _ignoreSelection,
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
    );

    expect(tabBar.height, 80);
  });

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

  testWidgets('uses a bounded default height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: NativeGlassTabBar(
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

    expect(tester.getSize(find.byType(NativeGlassTabBar)).height, 80);
  });
}

void _ignoreSelection(int index) {}
