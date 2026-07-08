import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  test('defaults to an explicit 36px height', () {
    final control = NativeGlassSegmentedControl(
      selectedIndex: 0,
      onSegmentSelected: _ignoreSelection,
      segments: const [
        NativeGlassSegment(label: 'Day'),
        NativeGlassSegment(label: 'Week'),
      ],
    );

    expect(control.height, 36);
  });

  testWidgets('calls onSegmentSelected from fallback segments', (tester) async {
    final selections = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NativeGlassSegmentedControl(
            selectedIndex: 0,
            renderMode: NativeGlassRenderMode.flutter,
            onSegmentSelected: selections.add,
            segments: const [
              NativeGlassSegment(label: 'Day'),
              NativeGlassSegment(label: 'Week'),
              NativeGlassSegment(label: 'Month'),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Week'));

    expect(selections, [1]);
  });

  testWidgets('clamps out-of-range selectedIndex for fallback rendering', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NativeGlassSegmentedControl(
            selectedIndex: 99,
            renderMode: NativeGlassRenderMode.flutter,
            onSegmentSelected: (_) {},
            segments: const [
              NativeGlassSegment(label: 'Day'),
              NativeGlassSegment(label: 'Week'),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not clip the Material fallback height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NativeGlassSegmentedControl(
            selectedIndex: 0,
            renderMode: NativeGlassRenderMode.flutter,
            onSegmentSelected: (_) {},
            segments: const [
              NativeGlassSegment(label: 'Day'),
              NativeGlassSegment(label: 'Week'),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(SegmentedButton<int>)).height,
      greaterThan(36),
    );
  });
}

void _ignoreSelection(int index) {}
