import UIKit

struct NativeGlassSegmentedControlProps {
  struct Segment {
    let label: String
    let icon: Icon?

    init?(payload: [String: Any]) {
      guard let label = payload["label"] as? String else { return nil }

      self.label = label

      if let iconPayload = payload["icon"] as? [String: Any] {
        icon = Icon(payload: iconPayload)
      } else {
        icon = nil
      }
    }
  }

  enum Icon {
    case sfSymbol(String)
    case nativeAsset(String)
    case unsupported

    init?(payload: [String: Any]) {
      guard let type = payload["type"] as? String else { return nil }
      switch type {
      case "sf_symbol":
        guard let name = payload["name"] as? String else { return nil }
        self = .sfSymbol(name)
      case "native_asset":
        guard let name = payload["name"] as? String else { return nil }
        self = .nativeAsset(name)
      default:
        self = .unsupported
      }
    }

    func image() -> UIImage? {
      switch self {
      case .sfSymbol(let name):
        return UIImage(systemName: name)
      case .nativeAsset(let name):
        return UIImage(named: name)
      case .unsupported:
        return UIImage(systemName: "questionmark.circle")
      }
    }
  }

  let selectedIndex: Int
  let segments: [Segment]

  init?(payload: [String: Any]) {
    guard
      let selectedIndex = payload["selected_index"] as? Int,
      let segmentPayloads = payload["segments"] as? [[String: Any]]
    else {
      return nil
    }

    let segments = segmentPayloads.compactMap(Segment.init(payload:))
    guard segments.count == segmentPayloads.count else { return nil }
    guard segments.count >= 2 && segments.count <= 5 else { return nil }

    self.selectedIndex = selectedIndex
    self.segments = segments
  }
}
