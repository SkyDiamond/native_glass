import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  test('defaults to a Material toolbar height', () {
    final navigationBar = NativeGlassNavigationBar(
      title: 'Portfolio',
      onActionSelected: _ignoreAction,
    );

    expect(navigationBar.height, kToolbarHeight);
    expect(navigationBar.preferredSize.height, kToolbarHeight);
  });

  testWidgets('calls onActionSelected from fallback actions', (tester) async {
    final actions = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: NativeGlassNavigationBar(
            title: 'Portfolio',
            renderMode: NativeGlassRenderMode.flutter,
            leadingAction: const NativeGlassNavigationAction(
              id: 'back',
              label: 'Back',
              icon: NativeGlassIcon.flutterIcon(Icons.arrow_back),
            ),
            trailingActions: const [
              NativeGlassNavigationAction(
                id: 'search',
                label: 'Search',
                icon: NativeGlassIcon.flutterIcon(Icons.search),
              ),
            ],
            onActionSelected: actions.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.tap(find.byTooltip('Search'));

    expect(actions, ['back', 'search']);
  });
}

void _ignoreAction(String id) {}
