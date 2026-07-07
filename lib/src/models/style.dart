import 'package:flutter/widgets.dart';

class NativeGlassStyle {
  const NativeGlassStyle({
    this.tintColor,
    this.backgroundTint,
    this.borderColor,
    this.borderRadius,
    this.blur = 18,
    this.opacity = 0.72,
  });

  final Color? tintColor;
  final Color? backgroundTint;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final double opacity;

  NativeGlassStyle copyWith({
    Color? tintColor,
    Color? backgroundTint,
    Color? borderColor,
    BorderRadiusGeometry? borderRadius,
    double? blur,
    double? opacity,
  }) {
    return NativeGlassStyle(
      tintColor: tintColor ?? this.tintColor,
      backgroundTint: backgroundTint ?? this.backgroundTint,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      blur: blur ?? this.blur,
      opacity: opacity ?? this.opacity,
    );
  }

  NativeGlassStyle merge(NativeGlassStyle? other) {
    if (other == null) return this;
    return copyWith(
      tintColor: other.tintColor,
      backgroundTint: other.backgroundTint,
      borderColor: other.borderColor,
      borderRadius: other.borderRadius,
      blur: other.blur,
      opacity: other.opacity,
    );
  }
}
