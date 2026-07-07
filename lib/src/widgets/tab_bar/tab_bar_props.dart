import '../../models/destination.dart';

class NativeGlassTabBarProps {
  const NativeGlassTabBarProps({
    required this.selectedIndex,
    required this.destinations,
  });

  final int selectedIndex;
  final List<NativeGlassDestination> destinations;

  Map<String, Object?> toProps() {
    return {
      'selected_index': selectedIndex,
      'destinations': [
        for (final destination in destinations) destination.toNativeProps(),
      ],
    };
  }

  Map<String, Object?> toCreationParams() {
    return {'schema_version': 1, 'component': 'tabBar', 'props': toProps()};
  }
}
