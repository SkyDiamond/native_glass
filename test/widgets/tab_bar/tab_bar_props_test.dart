import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';
import 'package:native_glass/src/widgets/tab_bar/tab_bar_props.dart';

void main() {
  test('serializes tab bar props with schema version and snake case keys', () {
    final props = NativeGlassTabBarProps(
      selectedIndex: 1,
      destinations: const [
        NativeGlassDestination(
          label: 'Home',
          icon: NativeGlassIcon.sfSymbol('house'),
          selectedIcon: NativeGlassIcon.sfSymbol('house.fill'),
        ),
        NativeGlassDestination(
          label: 'Search',
          icon: NativeGlassIcon.flutterIcon(Icons.search),
          badge: NativeGlassBadge.dot(),
        ),
      ],
    );

    expect(props.toCreationParams(), {
      'schema_version': 1,
      'component': 'tabBar',
      'props': {
        'selected_index': 1,
        'destinations': [
          {
            'label': 'Home',
            'icon': {'type': 'sf_symbol', 'name': 'house'},
            'selected_icon': {'type': 'sf_symbol', 'name': 'house.fill'},
          },
          {
            'label': 'Search',
            'icon': {
              'type': 'flutter_icon',
              'code_point': Icons.search.codePoint,
              'font_family': Icons.search.fontFamily,
              'font_package': Icons.search.fontPackage,
              'match_text_direction': Icons.search.matchTextDirection,
            },
            'badge': {'type': 'dot'},
          },
        ],
      },
    });
  });
}
