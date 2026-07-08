import 'package:flutter/material.dart';

import '../../adaptive/availability.dart';
import '../../adaptive/render_policy.dart';
import '../../adaptive/theme.dart';
import '../../diagnostics/diagnostic_event.dart';
import '../../diagnostics/diagnostics.dart';
import '../../models/navigation_action.dart';
import '../../platform_view/native_host_view.dart';
import 'fallback_navigation_bar.dart';
import 'navigation_bar_props.dart';

class NativeGlassNavigationBar extends StatefulWidget
    implements PreferredSizeWidget {
  const NativeGlassNavigationBar({
    super.key,
    required this.title,
    this.leadingAction,
    this.trailingActions = const [],
    this.onActionSelected,
    this.renderMode,
    this.height = kToolbarHeight,
  });

  final String title;
  final NativeGlassNavigationAction? leadingAction;
  final List<NativeGlassNavigationAction> trailingActions;
  final ValueChanged<String>? onActionSelected;
  final NativeGlassRenderMode? renderMode;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<NativeGlassNavigationBar> createState() =>
      _NativeGlassNavigationBarState();
}

class _NativeGlassNavigationBarState extends State<NativeGlassNavigationBar> {
  String? _lastDiagnosticSignature;

  @override
  Widget build(BuildContext context) {
    final fallback = FallbackNativeGlassNavigationBar(
      title: widget.title,
      height: widget.height,
      leadingAction: widget.leadingAction,
      trailingActions: widget.trailingActions,
      onActionSelected: widget.onActionSelected,
    );
    final theme = NativeGlassTheme.of(context);
    final props = NativeGlassNavigationBarProps(
      title: widget.title,
      leadingAction: widget.leadingAction,
      trailingActions: widget.trailingActions,
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

        if (decision.renderer == NativeGlassRenderer.flutterFallback) {
          return fallback;
        }

        return SizedBox(
          height: widget.height,
          child: NativeGlassNativeHostView(
            creationParams: props.toCreationParams(),
            props: props.toProps(),
            structuralSignature: (
              widget.leadingAction != null,
              widget.trailingActions.length,
            ),
            warnWhenTooManyPlatformViews:
                theme.config.warnWhenTooManyPlatformViews,
            onEvent: (call) {
              if (call.method != 'onActionSelected') return;
              final arguments = call.arguments;
              if (arguments is Map && arguments['id'] is String) {
                widget.onActionSelected?.call(arguments['id'] as String);
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
              'NativeGlassNavigationBar rendered with '
              '${decision.renderer.name}. '
              'Reason: ${decision.diagnosticMessage}',
          fallbackReason: decision.fallbackReason,
        ),
      );
    });
  }
}
