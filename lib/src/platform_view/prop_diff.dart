Map<String, Object?> diffProps(
  Map<String, Object?>? previous,
  Map<String, Object?> next,
) {
  if (previous == null) return Map<String, Object?>.from(next);

  final diff = <String, Object?>{};
  final keys = <String>{...previous.keys, ...next.keys};

  for (final key in keys) {
    final previousHasKey = previous.containsKey(key);
    final nextHasKey = next.containsKey(key);
    if (!previousHasKey || !nextHasKey) {
      diff[key] = next[key];
      continue;
    }

    if (!_deepEquals(previous[key], next[key])) {
      diff[key] = next[key];
    }
  }

  return diff;
}

bool _deepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!_deepEquals(a[key], b[key])) return false;
    }
    return true;
  }

  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }

  return a == b;
}
