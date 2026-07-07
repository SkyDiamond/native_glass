import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/models/icon.dart';

void main() {
  test('serializes SF Symbols for native props', () {
    const icon = NativeGlassIcon.sfSymbol('house.fill');

    expect(icon.toNativeProps(), {'type': 'sf_symbol', 'name': 'house.fill'});
  });

  test('serializes Native Assets without treating them as Flutter assets', () {
    const icon = NativeGlassIcon.nativeAsset('tab_home_selected');

    expect(icon.toNativeProps(), {
      'type': 'native_asset',
      'name': 'tab_home_selected',
    });
  });

  test('marks Flutter icons as fallback-only in native props', () {
    const icon = NativeGlassIcon.flutterIcon(Icons.home);

    expect(icon.toNativeProps(), {
      'type': 'flutter_icon',
      'code_point': Icons.home.codePoint,
      'font_family': Icons.home.fontFamily,
      'font_package': Icons.home.fontPackage,
      'match_text_direction': Icons.home.matchTextDirection,
    });
  });
}
