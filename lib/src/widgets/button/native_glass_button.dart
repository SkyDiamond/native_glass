import 'package:flutter/material.dart';

import '../container/native_glass_container.dart';

class NativeGlassButton extends StatefulWidget {
  const NativeGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.borderRadius,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<NativeGlassButton> createState() => _NativeGlassButtonState();
}

class _NativeGlassButtonState extends State<NativeGlassButton> {
  var _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tintColor = _enabled
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    return Semantics(
      button: true,
      enabled: _enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 90),
          child: NativeGlassContainer(
            padding: widget.padding,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            tintColor: tintColor,
            opacity: _enabled ? 0.62 : 0.36,
            blur: 12,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: _enabled
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: _enabled
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }
}
