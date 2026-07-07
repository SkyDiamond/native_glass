import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass/native_glass.dart';
import 'package:native_glass/native_glass_platform_interface.dart';
import 'package:native_glass/native_glass_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeGlassPlatform
    with MockPlatformInterfaceMixin
    implements NativeGlassPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeGlassPlatform initialPlatform = NativeGlassPlatform.instance;

  test('$MethodChannelNativeGlass is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeGlass>());
  });

  test('getPlatformVersion', () async {
    NativeGlass nativeGlassPlugin = NativeGlass();
    MockNativeGlassPlatform fakePlatform = MockNativeGlassPlatform();
    NativeGlassPlatform.instance = fakePlatform;

    expect(await nativeGlassPlugin.getPlatformVersion(), '42');
  });
}
