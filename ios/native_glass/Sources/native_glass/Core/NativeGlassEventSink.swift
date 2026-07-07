import Flutter

final class NativeGlassEventSink {
  private weak var channel: FlutterMethodChannel?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  func send(_ method: String, arguments: Any? = nil) {
    channel?.invokeMethod(method, arguments: arguments)
  }
}
