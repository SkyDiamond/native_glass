import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/models/badge.dart';

void main() {
  test('serializes count badges', () {
    expect(const NativeGlassBadge.count(3).toNativeProps(), {
      'type': 'count',
      'value': 3,
    });
  });

  test('serializes text badges', () {
    expect(const NativeGlassBadge.text('NEW').toNativeProps(), {
      'type': 'text',
      'value': 'NEW',
    });
  });

  test('serializes dot badges without a text value', () {
    expect(const NativeGlassBadge.dot().toNativeProps(), {'type': 'dot'});
  });
}
