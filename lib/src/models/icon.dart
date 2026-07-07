import 'package:flutter/widgets.dart';

sealed class NativeGlassIcon {
  const NativeGlassIcon();

  const factory NativeGlassIcon.sfSymbol(String name) = NativeGlassSfSymbolIcon;

  const factory NativeGlassIcon.nativeAsset(String name) =
      NativeGlassNativeAssetIcon;

  const factory NativeGlassIcon.flutterIcon(IconData icon) =
      NativeGlassFlutterIcon;

  Map<String, Object?> toNativeProps();
}

final class NativeGlassSfSymbolIcon extends NativeGlassIcon {
  const NativeGlassSfSymbolIcon(this.name);

  final String name;

  @override
  Map<String, Object?> toNativeProps() {
    return {'type': 'sf_symbol', 'name': name};
  }
}

final class NativeGlassNativeAssetIcon extends NativeGlassIcon {
  const NativeGlassNativeAssetIcon(this.name);

  final String name;

  @override
  Map<String, Object?> toNativeProps() {
    return {'type': 'native_asset', 'name': name};
  }
}

final class NativeGlassFlutterIcon extends NativeGlassIcon {
  const NativeGlassFlutterIcon(this.icon);

  final IconData icon;

  @override
  Map<String, Object?> toNativeProps() {
    return {
      'type': 'flutter_icon',
      'code_point': icon.codePoint,
      'font_family': icon.fontFamily,
      'font_package': icon.fontPackage,
      'match_text_direction': icon.matchTextDirection,
    };
  }
}
