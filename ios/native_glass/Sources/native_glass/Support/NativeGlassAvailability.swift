import UIKit

enum NativeGlassAvailability {
  static func currentPayload() -> [String: Any] {
    return [
      "is_ios": true,
      "ios_version": UIDevice.current.systemVersion,
      "supports_native_renderer": true,
      "supports_liquid_glass": supportsLiquidGlass,
    ]
  }

  private static var supportsLiquidGlass: Bool {
    if #available(iOS 26.0, *) {
      return true
    }
    return false
  }
}
