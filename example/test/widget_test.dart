import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass_example/main.dart';

void main() {
  testWidgets('navigates across the five example demos', (tester) async {
    await tester.pumpWidget(const NativeGlassExampleApp());

    expect(find.text('Showcase'), findsWidgets);
    expect(find.text('Component Showcase'), findsOneWidget);

    await tester.tap(find.text('Tab Bar').last);
    await tester.pumpAndSettle();
    expect(find.text('Tab Bar Demo'), findsOneWidget);

    await tester.tap(find.text('Surfaces').last);
    await tester.pumpAndSettle();
    expect(find.text('Controls And Surfaces Demo'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);

    await tester.tap(find.text('Policy').last);
    await tester.pumpAndSettle();
    expect(find.text('Render Policy Demo'), findsOneWidget);

    await tester.tap(find.text('Diagnostics').last);
    await tester.pumpAndSettle();
    expect(find.text('Diagnostics Demo'), findsOneWidget);

    await tester.tap(find.byTooltip('Policy').last);
    await tester.pumpAndSettle();
    expect(find.text('Render Policy Demo'), findsOneWidget);

    await tester.tap(find.byTooltip('Diagnostics').last);
    await tester.pumpAndSettle();
    expect(find.text('Diagnostics Demo'), findsOneWidget);
  });
}
