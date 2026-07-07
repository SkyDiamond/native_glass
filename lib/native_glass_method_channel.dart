import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_glass_platform_interface.dart';

/// An implementation of [NativeGlassPlatform] that uses method channels.
class MethodChannelNativeGlass extends NativeGlassPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_glass');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
