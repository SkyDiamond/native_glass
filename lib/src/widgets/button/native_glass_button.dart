import 'package:flutter/widgets.dart';

class NativeGlassButton extends StatelessWidget {
  const NativeGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(onTap: onPressed, child: child),
    );
  }
}
