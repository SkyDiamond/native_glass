class NativeGlassButtonProps {
  const NativeGlassButtonProps({
    required this.label,
    required this.enabled,
  });

  final String label;
  final bool enabled;

  Map<String, Object?> toProps() {
    return {'label': label, 'enabled': enabled};
  }

  Map<String, Object?> toCreationParams() {
    return {
      'schema_version': 1,
      'component': 'button',
      'props': toProps(),
    };
  }
}
