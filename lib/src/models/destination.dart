import 'badge.dart';
import 'icon.dart';

class NativeGlassDestination {
  const NativeGlassDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  final String label;
  final NativeGlassIcon icon;
  final NativeGlassIcon? selectedIcon;
  final NativeGlassBadge? badge;

  Map<String, Object?> toNativeProps() {
    return {
      'label': label,
      'icon': icon.toNativeProps(),
      if (selectedIcon != null) 'selected_icon': selectedIcon!.toNativeProps(),
      if (badge != null) 'badge': badge!.toNativeProps(),
    };
  }
}
