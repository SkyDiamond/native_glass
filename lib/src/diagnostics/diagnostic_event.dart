import '../adaptive/render_policy.dart';

class NativeGlassDiagnosticEvent {
  const NativeGlassDiagnosticEvent({
    required this.message,
    this.fallbackReason,
    this.activeNativeRendererCount,
    this.visibleNativeRendererCount,
    this.propUpdateCount,
    this.structuralRebuildCount,
  });

  final String message;
  final NativeGlassFallbackReason? fallbackReason;
  final int? activeNativeRendererCount;
  final int? visibleNativeRendererCount;
  final int? propUpdateCount;
  final int? structuralRebuildCount;
}
