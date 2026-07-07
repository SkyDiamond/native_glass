import 'package:flutter/widgets.dart';

import '../models/style.dart';
import 'config.dart';

class NativeGlassThemeData {
  const NativeGlassThemeData({
    this.config = const NativeGlassConfig(),
    this.style = const NativeGlassStyle(),
  });

  final NativeGlassConfig config;
  final NativeGlassStyle style;

  NativeGlassThemeData copyWith({
    NativeGlassConfig? config,
    NativeGlassStyle? style,
  }) {
    return NativeGlassThemeData(
      config: config ?? this.config,
      style: style ?? this.style,
    );
  }
}

class NativeGlassTheme extends InheritedWidget {
  const NativeGlassTheme({super.key, required this.data, required super.child});

  final NativeGlassThemeData data;

  static NativeGlassThemeData of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<NativeGlassTheme>()
            ?.data ??
        const NativeGlassThemeData();
  }

  @override
  bool updateShouldNotify(NativeGlassTheme oldWidget) {
    return data != oldWidget.data;
  }
}
