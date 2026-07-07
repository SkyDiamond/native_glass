import 'icon.dart';

class NativeGlassNavigationAction {
  const NativeGlassNavigationAction({
    required this.id,
    required this.label,
    this.icon,
  });

  final String id;
  final String label;
  final NativeGlassIcon? icon;

  Map<String, Object?> toNativeProps() {
    return {
      'id': id,
      'label': label,
      if (icon != null) 'icon': icon!.toNativeProps(),
    };
  }
}
