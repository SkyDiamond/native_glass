import 'icon.dart';

class NativeGlassSegment {
  const NativeGlassSegment({required this.label, this.icon});

  final String label;
  final NativeGlassIcon? icon;

  Map<String, Object?> toNativeProps() {
    return {'label': label, if (icon != null) 'icon': icon!.toNativeProps()};
  }
}
