import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';

void main() {
  testWidgets('renders arbitrary Flutter children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NativeGlassContainer(child: Text('Inside glass')),
      ),
    );

    expect(find.text('Inside glass'), findsOneWidget);
  });

  testWidgets('applies padding around children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: NativeGlassContainer(
            padding: EdgeInsets.all(24),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(NativeGlassContainer));

    expect(size.width, 58);
    expect(size.height, 58);
  });

  testWidgets('degrades without BackdropFilter when blur is zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NativeGlassContainer(blur: 0, child: Text('Cheap surface')),
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Cheap surface'), findsOneWidget);
  });
}
