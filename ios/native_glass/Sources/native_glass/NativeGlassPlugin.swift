import Flutter
import UIKit

public class NativeGlassPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "native_glass",
      binaryMessenger: registrar.messenger()
    )
    let instance = NativeGlassPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    registrar.register(
      NativeGlassHostViewFactory(messenger: registrar.messenger()),
      withId: "native_glass/host"
    )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getAvailability":
      result(NativeGlassAvailability.currentPayload())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
