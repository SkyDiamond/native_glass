import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';
import 'package:native_glass/src/widgets/navigation_bar/navigation_bar_props.dart';

void main() {
  test(
    'serializes navigation bar props with schema version and snake case keys',
    () {
      final props = NativeGlassNavigationBarProps(
        title: 'Portfolio',
        leadingAction: const NativeGlassNavigationAction(
          id: 'back',
          label: 'Back',
          icon: NativeGlassIcon.sfSymbol('chevron.left'),
        ),
        trailingActions: const [
          NativeGlassNavigationAction(
            id: 'search',
            label: 'Search',
            icon: NativeGlassIcon.sfSymbol('magnifyingglass'),
          ),
          NativeGlassNavigationAction(
            id: 'settings',
            label: 'Settings',
            icon: NativeGlassIcon.flutterIcon(Icons.settings),
          ),
        ],
      );

      expect(props.toCreationParams(), {
        'schema_version': 1,
        'component': 'navigationBar',
        'props': {
          'title': 'Portfolio',
          'leading_action': {
            'id': 'back',
            'label': 'Back',
            'icon': {'type': 'sf_symbol', 'name': 'chevron.left'},
          },
          'trailing_actions': [
            {
              'id': 'search',
              'label': 'Search',
              'icon': {'type': 'sf_symbol', 'name': 'magnifyingglass'},
            },
            {
              'id': 'settings',
              'label': 'Settings',
              'icon': {
                'type': 'flutter_icon',
                'code_point': Icons.settings.codePoint,
                'font_family': Icons.settings.fontFamily,
                'font_package': Icons.settings.fontPackage,
                'match_text_direction': Icons.settings.matchTextDirection,
              },
            },
          ],
        },
      });
    },
  );
}
