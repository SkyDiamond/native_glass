import 'package:flutter/material.dart';

import '../../adaptive/availability.dart';
import '../../adaptive/render_policy.dart';
import '../../adaptive/theme.dart';
import '../../diagnostics/diagnostic_event.dart';
import '../../diagnostics/diagnostics.dart';
import '../../models/segment.dart';
import '../../platform_view/native_host_view.dart';
import 'fallback_segmented_control.dart';
import 'segmented_control_props.dart';

class NativeGlassSegmentedControl extends StatefulWidget {
  const NativeGlassSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onSegmentSelected,
    required this.segments,
    this.renderMode,
    this.height = 36,
  }) : assert(segments.length >= 2 && segments.length <= 5);

  final int selectedIndex;
  final ValueChanged<int> onSegmentSelected;
  final List<NativeGlassSegment> segments;
  final NativeGlassRenderMode? renderMode;
  final double height;

  @override
  State<NativeGlassSegmentedControl> createState() =>
      _NativeGlassSegmentedControlState();
}

class _NativeGlassSegmentedControlState
    extends State<NativeGlassSegmentedControl> {
  String? _lastDiagnosticSignature;

  @override
  Widget build(BuildContext context) {
    final fallback = ConstrainedBox(
      constraints: BoxConstraints(minHeight: widget.height),
      child: FallbackNativeGlassSegmentedControl(
        selectedIndex: widget.selectedIndex,
        onSegmentSelected: widget.onSegmentSelected,
        segments: widget.segments,
      ),
    );
    final theme = NativeGlassTheme.of(context);
    final props = NativeGlassSegmentedControlProps(
      selectedIndex: widget.selectedIndex,
      segments: widget.segments,
    );

    return FutureBuilder<NativeGlassAvailability>(
      future: NativeGlassAvailability.check(),
      builder: (context, snapshot) {
        final availability = snapshot.data;
        if (availability == null) return fallback;

        final decision = resolveNativeGlassRenderPolicy(
          component: NativeGlassComponentRole.nativeLeafControl,
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
            onEvent: (call) {
              if (call.method != 'onSegmentSelected') return;
              final arguments = call.arguments;
              if (arguments is Map && arguments['index'] is int) {
                widget.onSegmentSelected(arguments['index'] as int);
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
              'NativeGlassSegmentedControl rendered with '
              '${decision.renderer.name}. '
              'Reason: ${decision.diagnosticMessage}',
          fallbackReason: decision.fallbackReason,
        ),
      );
    });
  }
}
