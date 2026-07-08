import '../../models/segment.dart';

class NativeGlassSegmentedControlProps {
  const NativeGlassSegmentedControlProps({
    required this.selectedIndex,
    required this.segments,
  });

  final int selectedIndex;
  final List<NativeGlassSegment> segments;

  Map<String, Object?> toProps() {
    return {
      'selected_index': selectedIndex,
      'segments': [for (final segment in segments) segment.toNativeProps()],
    };
  }

  Map<String, Object?> toCreationParams() {
    return {
      'schema_version': 1,
      'component': 'segmentedControl',
      'props': toProps(),
    };
  }
}
