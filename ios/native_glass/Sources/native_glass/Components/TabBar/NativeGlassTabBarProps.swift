import UIKit

struct NativeGlassTabBarProps {
  struct Destination {
    let label: String
    let icon: Icon
    let selectedIcon: Icon?
    let badge: Badge?

    init?(payload: [String: Any]) {
      guard
        let label = payload["label"] as? String,
        let iconPayload = payload["icon"] as? [String: Any],
        let icon = Icon(payload: iconPayload)
      else {
        return nil
      }

      self.label = label
      self.icon = icon

      if let selectedPayload = payload["selected_icon"] as? [String: Any] {
        selectedIcon = Icon(payload: selectedPayload)
      } else {
        selectedIcon = nil
      }

      if let badgePayload = payload["badge"] as? [String: Any] {
        badge = Badge(payload: badgePayload)
      } else {
        badge = nil
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

    var usesOriginalRenderingWhenSelected: Bool {
      switch self {
      case .nativeAsset:
        return true
      case .sfSymbol, .unsupported:
        return false
      }
    }
  }

  enum Badge {
    case count(Int)
    case text(String)
    case dot

    init?(payload: [String: Any]) {
      guard let type = payload["type"] as? String else { return nil }
      switch type {
      case "count":
        guard let value = payload["value"] as? Int else { return nil }
        self = .count(value)
      case "text":
        guard let value = payload["value"] as? String else { return nil }
        self = .text(value)
      case "dot":
        self = .dot
      default:
        return nil
      }
    }

    var value: String? {
      switch self {
      case .count(let value):
        return "\(value)"
      case .text(let value):
        return value
      case .dot:
        return ""
      }
    }
  }

  let selectedIndex: Int
  let destinations: [Destination]

  init?(payload: [String: Any]) {
    guard
      let selectedIndex = payload["selected_index"] as? Int,
      let destinationPayloads = payload["destinations"] as? [[String: Any]]
    else {
      return nil
    }

    let destinations = destinationPayloads.compactMap(Destination.init(payload:))
    guard destinations.count == destinationPayloads.count else { return nil }
    guard destinations.count >= 2 && destinations.count <= 5 else { return nil }

    self.selectedIndex = selectedIndex
    self.destinations = destinations
  }
}
