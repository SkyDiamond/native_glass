import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';
import 'package:native_glass/src/widgets/segmented_control/segmented_control_props.dart';

void main() {
  test(
    'serializes segmented control props with schema version and snake case keys',
    () {
      final props = NativeGlassSegmentedControlProps(
        selectedIndex: 1,
        segments: const [
          NativeGlassSegment(
            label: 'Day',
            icon: NativeGlassIcon.sfSymbol('sun.max'),
          ),
          NativeGlassSegment(
            label: 'Week',
            icon: NativeGlassIcon.flutterIcon(Icons.calendar_view_week),
          ),
        ],
      );

      expect(props.toCreationParams(), {
        'schema_version': 1,
        'component': 'segmentedControl',
        'props': {
          'selected_index': 1,
          'segments': [
            {
              'label': 'Day',
              'icon': {'type': 'sf_symbol', 'name': 'sun.max'},
            },
            {
              'label': 'Week',
              'icon': {
                'type': 'flutter_icon',
                'code_point': Icons.calendar_view_week.codePoint,
                'font_family': Icons.calendar_view_week.fontFamily,
                'font_package': Icons.calendar_view_week.fontPackage,
                'match_text_direction':
                    Icons.calendar_view_week.matchTextDirection,
              },
            },
          ],
        },
      });
    },
  );
}
