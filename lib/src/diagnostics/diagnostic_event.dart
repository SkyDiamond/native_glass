import '../adaptive/render_policy.dart';

class NativeGlassDiagnosticEvent {
  const NativeGlassDiagnosticEvent({
    required this.message,
    this.fallbackReason,
  });

  final String message;
  final NativeGlassFallbackReason? fallbackReason;
}
