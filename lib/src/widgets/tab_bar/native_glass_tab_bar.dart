import 'package:flutter/widgets.dart';

import '../../adaptive/availability.dart';
import '../../adaptive/render_policy.dart';
import '../../adaptive/theme.dart';
import '../../diagnostics/diagnostic_event.dart';
import '../../diagnostics/diagnostics.dart';
import '../../models/destination.dart';
import '../../platform_view/native_host_view.dart';
import 'fallback_tab_bar.dart';
import 'tab_bar_props.dart';

class NativeGlassTabBar extends StatefulWidget {
  const NativeGlassTabBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.renderMode,
    this.height = 80,
  }) : assert(destinations.length >= 2 && destinations.length <= 5);

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NativeGlassDestination> destinations;
  final NativeGlassRenderMode? renderMode;
  final double height;

  @override
  State<NativeGlassTabBar> createState() => _NativeGlassTabBarState();
}

class _NativeGlassTabBarState extends State<NativeGlassTabBar> {
  String? _lastDiagnosticSignature;

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox(
      height: widget.height,
      child: FallbackNativeGlassTabBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
        destinations: widget.destinations,
      ),
    );
    final theme = NativeGlassTheme.of(context);
    final props = NativeGlassTabBarProps(
      selectedIndex: widget.selectedIndex,
      destinations: widget.destinations,
    );

    return FutureBuilder<NativeGlassAvailability>(
      future: NativeGlassAvailability.check(),
      builder: (context, snapshot) {
        final availability = snapshot.data;
        if (availability == null) return fallback;

        final decision = resolveNativeGlassRenderPolicy(
          component: NativeGlassComponentRole.systemSurface,
          requestedMode: widget.renderMode,
          config: theme.config,
          availability: availability,
        );
        _scheduleRenderDecisionDiagnostic(
          decision,
          theme.config.diagnosticsEnabled,
        );
        enforceNativeGlassFailureBehavior(decision);

        if (decision.renderer == NativeGlassRenderer.flutterFallback) {
          return fallback;
        }

        return SizedBox(
          height: widget.height,
          child: NativeGlassNativeHostView(
            creationParams: props.toCreationParams(),
            props: props.toProps(),
            structuralSignature: widget.destinations.length,
            warnWhenTooManyPlatformViews:
                theme.config.diagnosticsEnabled &&
                theme.config.warnWhenTooManyPlatformViews,
            onEvent: (call) {
              if (call.method != 'onDestinationSelected') return;
              final arguments = call.arguments;
              if (arguments is Map && arguments['index'] is int) {
                widget.onDestinationSelected(arguments['index'] as int);
              }
            },
          ),
        );
      },
    );
  }

  void _scheduleRenderDecisionDiagnostic(
    NativeGlassRenderDecision decision,
    bool diagnosticsEnabled,
  ) {
    if (!diagnosticsEnabled) return;
    final signature = [
      decision.renderer.name,
      decision.fallbackReason.name,
      decision.diagnosticMessage,
    ].join('|');
    if (_lastDiagnosticSignature == signature) return;
    _lastDiagnosticSignature = signature;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NativeGlassDiagnostics.emit(
        NativeGlassDiagnosticEvent(
          message:
              'NativeGlassTabBar rendered with ${decision.renderer.name}. '
              'Reason: ${decision.diagnosticMessage}',
          fallbackReason: decision.fallbackReason,
        ),
      );
    });
  }
}
