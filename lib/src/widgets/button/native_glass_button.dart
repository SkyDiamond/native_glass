import 'package:flutter/material.dart';

import '../../adaptive/availability.dart';
import '../../adaptive/render_policy.dart';
import '../../adaptive/theme.dart';
import '../../diagnostics/diagnostic_event.dart';
import '../../diagnostics/diagnostics.dart';
import '../../platform_view/native_host_view.dart';
import '../container/native_glass_container.dart';
import 'button_props.dart';

class NativeGlassButton extends StatefulWidget {
  const NativeGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.renderMode,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.borderRadius,
    this.height = 48,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final NativeGlassRenderMode? renderMode;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final double height;

  @override
  State<NativeGlassButton> createState() => _NativeGlassButtonState();
}

class _NativeGlassButtonState extends State<NativeGlassButton> {
  var _pressed = false;
  String? _lastDiagnosticSignature;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final fallback = _buildFallback(context);
    final nativeLabel = _nativeLabelFor(widget.child);
    if (nativeLabel == null) return fallback;

    final theme = NativeGlassTheme.of(context);
    final props = NativeGlassButtonProps(
      label: nativeLabel,
      enabled: _enabled,
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
              if (!_enabled || call.method != 'onPressed') return;
              widget.onPressed?.call();
            },
          ),
        );
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tintColor = _enabled
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    return Semantics(
      button: true,
      enabled: _enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 90),
          child: NativeGlassContainer(
            padding: widget.padding,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            tintColor: tintColor,
            opacity: _enabled ? 0.62 : 0.36,
            blur: 12,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: _enabled
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: _enabled
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _nativeLabelFor(Widget child) {
    if (child is Text && child.data != null) return child.data;
    return null;
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
              'NativeGlassButton rendered with ${decision.renderer.name}. '
              'Reason: ${decision.diagnosticMessage}',
          fallbackReason: decision.fallbackReason,
        ),
      );
    });
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }
}
