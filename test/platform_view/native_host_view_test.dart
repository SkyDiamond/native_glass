import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/platform_view/native_host_view.dart';

void main() {
  testWidgets('forwards pointer sequences eagerly to UIKit views', (
    tester,
  ) async {
    final previousTargetPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 100,
            height: 80,
            child: NativeGlassNativeHostView(
              creationParams: {
                'component': 'placeholder',
                'props': <String, Object?>{},
              },
              props: <String, Object?>{},
            ),
          ),
        ),
      );

      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      final recognizers = view.gestureRecognizers;

      expect(recognizers, isNotNull);
      expect(recognizers, hasLength(1));
      expect(
        recognizers!.single.constructor(),
        isA<EagerGestureRecognizer>(),
      );
    } finally {
      debugDefaultTargetPlatformOverride = previousTargetPlatform;
    }
  });
}
