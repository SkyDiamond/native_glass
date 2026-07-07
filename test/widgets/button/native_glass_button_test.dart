import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
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
}
