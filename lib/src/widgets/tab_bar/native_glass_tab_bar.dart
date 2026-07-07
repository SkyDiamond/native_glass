import 'package:flutter/widgets.dart';

import '../../adaptive/availability.dart';
import '../../adaptive/render_policy.dart';
import '../../adaptive/theme.dart';
import '../../models/destination.dart';
import '../../platform_view/native_host_view.dart';
import 'fallback_tab_bar.dart';
import 'tab_bar_props.dart';

class NativeGlassTabBar extends StatelessWidget {
  const NativeGlassTabBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.renderMode,
  }) : assert(destinations.length >= 2 && destinations.length <= 5);

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NativeGlassDestination> destinations;
  final NativeGlassRenderMode? renderMode;

  @override
  Widget build(BuildContext context) {
    final fallback = FallbackNativeGlassTabBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
    );
    final theme = NativeGlassTheme.of(context);
    final props = NativeGlassTabBarProps(
      selectedIndex: selectedIndex,
      destinations: destinations,
    );

    return FutureBuilder<NativeGlassAvailability>(
      future: NativeGlassAvailability.check(),
      builder: (context, snapshot) {
        final availability = snapshot.data;
        if (availability == null) return fallback;

        final decision = resolveNativeGlassRenderPolicy(
          component: NativeGlassComponentRole.systemSurface,
          requestedMode: renderMode,
          config: theme.config,
          availability: availability,
        );

        if (decision.renderer == NativeGlassRenderer.flutterFallback) {
          return fallback;
        }

        return NativeGlassNativeHostView(
          creationParams: props.toCreationParams(),
          props: props.toProps(),
          onEvent: (call) {
            if (call.method != 'onDestinationSelected') return;
            final arguments = call.arguments;
            if (arguments is Map && arguments['index'] is int) {
              onDestinationSelected(arguments['index'] as int);
            }
          },
        );
      },
    );
  }
}
