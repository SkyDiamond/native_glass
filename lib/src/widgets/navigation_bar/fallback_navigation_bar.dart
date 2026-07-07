import 'package:flutter/material.dart';

import '../../models/icon.dart';
import '../../models/navigation_action.dart';

class FallbackNativeGlassNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FallbackNativeGlassNavigationBar({
    super.key,
    required this.title,
    required this.height,
    this.leadingAction,
    this.trailingActions = const [],
    this.onActionSelected,
  });

  final String title;
  final double height;
  final NativeGlassNavigationAction? leadingAction;
  final List<NativeGlassNavigationAction> trailingActions;
  final ValueChanged<String>? onActionSelected;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      toolbarHeight: height,
      leading: leadingAction == null
          ? null
          : _NavigationActionButton(
              action: leadingAction!,
              onPressed: onActionSelected,
            ),
      actions: [
        for (final action in trailingActions)
          _NavigationActionButton(action: action, onPressed: onActionSelected),
      ],
    );
  }
}

class _NavigationActionButton extends StatelessWidget {
  const _NavigationActionButton({required this.action, this.onPressed});

  final NativeGlassNavigationAction action;
  final ValueChanged<String>? onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = action.icon;
    final handlePressed = onPressed == null
        ? null
        : () => onPressed!(action.id);

    if (icon == null) {
      return TextButton(onPressed: handlePressed, child: Text(action.label));
    }

    return IconButton(
      tooltip: action.label,
      onPressed: handlePressed,
      icon: _NavigationActionIcon(icon: icon),
    );
  }
}

class _NavigationActionIcon extends StatelessWidget {
  const _NavigationActionIcon({required this.icon});

  final NativeGlassIcon icon;

  @override
  Widget build(BuildContext context) {
    return switch (icon) {
      NativeGlassFlutterIcon(:final icon) => Icon(icon),
      NativeGlassSfSymbolIcon() => const Icon(Icons.circle_outlined),
      NativeGlassNativeAssetIcon() => const Icon(Icons.image_outlined),
    };
  }
}
