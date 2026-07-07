import 'package:flutter/widgets.dart';

class NativeGlassContainer extends StatelessWidget {
  const NativeGlassContainer({
    super.key,
    this.padding,
    this.margin,
    this.child,
  });

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}
