import UIKit

struct NativeGlassButtonProps {
  let label: String
  let enabled: Bool

  init?(payload: [String: Any]) {
    guard
      let label = payload["label"] as? String,
      let enabled = payload["enabled"] as? Bool
    else {
      return nil
    }

    self.label = label
    self.enabled = enabled
  }
}
