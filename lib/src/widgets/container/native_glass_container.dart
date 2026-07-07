import 'dart:ui';

import 'package:flutter/material.dart';

class NativeGlassContainer extends StatelessWidget {
  const NativeGlassContainer({
    super.key,
    this.padding,
    this.margin,
    this.borderRadius,
    this.tintColor,
    this.opacity = 0.72,
    this.blur = 18,
    this.border,
    this.child,
  });

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? tintColor;
  final double opacity;
  final double blur;
  final BoxBorder? border;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);
    final color = (tintColor ?? Theme.of(context).colorScheme.surface)
        .withValues(alpha: opacity);
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border:
            border ??
            Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
        borderRadius: effectiveRadius,
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    final surface = blur <= 0
        ? decorated
        : BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: decorated,
          );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(borderRadius: effectiveRadius, child: surface),
    );
  }
}
