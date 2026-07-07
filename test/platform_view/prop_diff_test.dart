import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/platform_view/prop_diff.dart';

void main() {
  test('returns an empty diff for deeply equal props', () {
    final previous = {
      'selected_index': 0,
      'destinations': [
        {
          'label': 'Home',
          'icon': {'type': 'sf_symbol', 'name': 'house'},
        },
      ],
    };
    final next = {
      'selected_index': 0,
      'destinations': [
        {
          'label': 'Home',
          'icon': {'type': 'sf_symbol', 'name': 'house'},
        },
      ],
    };

    expect(diffProps(previous, next), isEmpty);
  });

  test('reports changed top-level keys when nested values differ', () {
    final previous = {
      'selected_index': 0,
      'destinations': [
        {
          'label': 'Home',
          'icon': {'type': 'sf_symbol', 'name': 'house'},
        },
      ],
    };
    final next = {
      'selected_index': 1,
      'destinations': [
        {
          'label': 'Start',
          'icon': {'type': 'sf_symbol', 'name': 'house'},
        },
      ],
    };

    expect(diffProps(previous, next), {
      'selected_index': 1,
      'destinations': next['destinations'],
    });
  });
}
