import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/src/widgets/button/button_props.dart';

void main() {
  test('serializes button props with schema version and snake case keys', () {
    const props = NativeGlassButtonProps(label: 'Continue', enabled: true);

    expect(props.toCreationParams(), {
      'schema_version': 1,
      'component': 'button',
      'props': {'label': 'Continue', 'enabled': true},
    });
  });
}
