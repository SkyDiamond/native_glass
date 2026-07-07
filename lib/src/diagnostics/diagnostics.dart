import 'dart:developer' as developer;

import 'diagnostic_event.dart';

typedef NativeGlassDiagnosticListener =
    void Function(NativeGlassDiagnosticEvent event);

class NativeGlassDiagnostics {
  NativeGlassDiagnostics._();

  static NativeGlassDiagnosticListener? listener;

  static void emit(NativeGlassDiagnosticEvent event) {
    developer.log(event.message, name: 'NativeGlass');
    listener?.call(event);
  }
}
