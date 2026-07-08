import 'package:flutter/material.dart';

import '../../models/icon.dart';
import '../../models/segment.dart';

class FallbackNativeGlassSegmentedControl extends StatelessWidget {
  const FallbackNativeGlassSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onSegmentSelected,
    required this.segments,
  });

  final int selectedIndex;
  final ValueChanged<int> onSegmentSelected;
  final List<NativeGlassSegment> segments;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: [
        for (final (index, segment) in segments.indexed)
          ButtonSegment<int>(
            value: index,
            label: Text(segment.label),
            icon: segment.icon == null
                ? null
                : _SegmentIcon(icon: segment.icon!),
          ),
      ],
      selected: {selectedIndex.clamp(0, segments.length - 1)},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        onSegmentSelected(selection.single);
      },
    );
  }
}

class _SegmentIcon extends StatelessWidget {
  const _SegmentIcon({required this.icon});

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
