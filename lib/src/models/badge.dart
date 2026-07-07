sealed class NativeGlassBadge {
  const NativeGlassBadge();

  const factory NativeGlassBadge.count(int value) = NativeGlassCountBadge;

  const factory NativeGlassBadge.text(String value) = NativeGlassTextBadge;

  const factory NativeGlassBadge.dot() = NativeGlassDotBadge;

  Map<String, Object?> toNativeProps();
}

final class NativeGlassCountBadge extends NativeGlassBadge {
  const NativeGlassCountBadge(this.value);

  final int value;

  @override
  Map<String, Object?> toNativeProps() {
    return {'type': 'count', 'value': value};
  }
}

final class NativeGlassTextBadge extends NativeGlassBadge {
  const NativeGlassTextBadge(this.value);

  final String value;

  @override
  Map<String, Object?> toNativeProps() {
    return {'type': 'text', 'value': value};
  }
}

final class NativeGlassDotBadge extends NativeGlassBadge {
  const NativeGlassDotBadge();

  @override
  Map<String, Object?> toNativeProps() {
    return {'type': 'dot'};
  }
}
