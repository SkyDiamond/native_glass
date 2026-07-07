import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/models/badge.dart';
import 'package:native_glass/src/models/destination.dart';
import 'package:native_glass/src/models/icon.dart';

void main() {
  test('serializes destination labels, icons, selected icons, and badges', () {
    const destination = NativeGlassDestination(
      label: 'Home',
      icon: NativeGlassIcon.sfSymbol('house'),
      selectedIcon: NativeGlassIcon.nativeAsset('home_active'),
      badge: NativeGlassBadge.count(2),
    );

    expect(destination.toNativeProps(), {
      'label': 'Home',
      'icon': {'type': 'sf_symbol', 'name': 'house'},
      'selected_icon': {'type': 'native_asset', 'name': 'home_active'},
      'badge': {'type': 'count', 'value': 2},
    });
  });
}
