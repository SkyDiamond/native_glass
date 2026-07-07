import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_glass_method_channel.dart';

abstract class NativeGlassPlatform extends PlatformInterface {
  /// Constructs a NativeGlassPlatform.
  NativeGlassPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeGlassPlatform _instance = MethodChannelNativeGlass();

  /// The default instance of [NativeGlassPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeGlass].
  static NativeGlassPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeGlassPlatform] when
  /// they register themselves.
  static set instance(NativeGlassPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
