import '../../models/navigation_action.dart';

class NativeGlassNavigationBarProps {
  const NativeGlassNavigationBarProps({
    required this.title,
    this.leadingAction,
    this.trailingActions = const [],
  });

  final String title;
  final NativeGlassNavigationAction? leadingAction;
  final List<NativeGlassNavigationAction> trailingActions;

  Map<String, Object?> toProps() {
    return {
      'title': title,
      if (leadingAction != null)
        'leading_action': leadingAction!.toNativeProps(),
      'trailing_actions': [
        for (final action in trailingActions) action.toNativeProps(),
      ],
    };
  }

  Map<String, Object?> toCreationParams() {
    return {
      'schema_version': 1,
      'component': 'navigationBar',
      'props': toProps(),
    };
  }
}
