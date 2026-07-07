import 'package:flutter/material.dart';

import '../../models/destination.dart';
import '../../models/icon.dart';

class FallbackNativeGlassTabBar extends StatelessWidget {
  const FallbackNativeGlassTabBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NativeGlassDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final destination in destinations)
          NavigationDestination(
            icon: _FallbackIcon(icon: destination.icon),
            selectedIcon: _FallbackIcon(
              icon: destination.selectedIcon ?? destination.icon,
            ),
            label: destination.label,
          ),
      ],
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.icon});

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
