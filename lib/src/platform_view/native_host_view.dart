import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../diagnostics/diagnostics.dart';
import 'prop_diff.dart';

typedef NativeGlassViewEventHandler = void Function(MethodCall call);

final _nativeGlassGestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
};

class NativeGlassNativeHostView extends StatefulWidget {
  const NativeGlassNativeHostView({
    super.key,
    required this.creationParams,
    required this.props,
    this.structuralSignature,
    this.warnWhenTooManyPlatformViews = true,
    this.onEvent,
  });

  static const viewType = 'native_glass/host';

  final Map<String, Object?> creationParams;
  final Map<String, Object?> props;
  final Object? structuralSignature;
  final bool warnWhenTooManyPlatformViews;
  final NativeGlassViewEventHandler? onEvent;

  @override
  State<NativeGlassNativeHostView> createState() =>
      _NativeGlassNativeHostViewState();
}

class _NativeGlassNativeHostViewState extends State<NativeGlassNativeHostView> {
  MethodChannel? _channel;
  Map<String, Object?>? _previousProps;
  Map<String, Object?>? _pendingProps;
  NativeGlassRendererRegistration? _diagnosticsRegistration;
  var _isVisible = true;
  bool? _lastNativeVisibility;

  @override
  void initState() {
    super.initState();
    _previousProps = widget.props;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDiagnosticsVisibility();
  }

  @override
  void didUpdateWidget(NativeGlassNativeHostView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.structuralSignature != widget.structuralSignature) {
      NativeGlassDiagnostics.recordStructuralRebuild();
    }
    _syncDiagnosticsVisibility();
    _syncProps(widget.props);
  }

  @override
  void dispose() {
    _channel?.invokeMethod<void>('dispose');
    _channel?.setMethodCallHandler(null);
    _diagnosticsRegistration?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    return UiKitView(
      viewType: NativeGlassNativeHostView.viewType,
      creationParams: widget.creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: _nativeGlassGestureRecognizers,
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }

  void _onPlatformViewCreated(int id) {
    _diagnosticsRegistration ??= NativeGlassDiagnostics.registerNativeRenderer(
      visible: _isVisible,
      warnWhenTooManyPlatformViews: widget.warnWhenTooManyPlatformViews,
    );
    final channel = MethodChannel('native_glass/view_$id');
    channel.setMethodCallHandler((call) async {
      widget.onEvent?.call(call);
    });
    _channel = channel;
    _notifyNativeHandlerReady(channel);
    _syncNativeVisibility(force: true);

    final pendingProps = _pendingProps;
    if (pendingProps != null) {
      _pendingProps = null;
      _syncProps(pendingProps);
    }
  }

  void _syncDiagnosticsVisibility() {
    final route = ModalRoute.of(context);
    _isVisible =
        TickerMode.valuesOf(context).enabled && (route?.isCurrent ?? true);
    _diagnosticsRegistration?.setVisible(
      _isVisible,
      warnWhenTooManyPlatformViews: widget.warnWhenTooManyPlatformViews,
    );
    _syncNativeVisibility();
  }

  void _notifyNativeHandlerReady(MethodChannel channel) {
    unawaited(channel.invokeMethod<void>('ready').catchError((Object _) {}));
  }

  void _syncNativeVisibility({bool force = false}) {
    final channel = _channel;
    if (channel == null) return;
    if (!force && _lastNativeVisibility == _isVisible) return;
    _lastNativeVisibility = _isVisible;
    unawaited(
      channel
          .invokeMethod<void>('setVisible', {'visible': _isVisible})
          .catchError((Object _) {}),
    );
  }

  void _syncProps(Map<String, Object?> nextProps) {
    final diff = diffProps(_previousProps, nextProps);
    if (diff.isEmpty) return;

    final channel = _channel;
    if (channel == null) {
      _pendingProps = nextProps;
      return;
    }

    channel.invokeMethod<void>('updateProps', {
      'schema_version': 1,
      'props': nextProps,
      'diff': diff,
    });
    NativeGlassDiagnostics.recordPropUpdate();
    _previousProps = nextProps;
  }
}
