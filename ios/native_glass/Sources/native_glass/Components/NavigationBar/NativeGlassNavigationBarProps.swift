import UIKit

struct NativeGlassNavigationBarProps {
  struct Action {
    let id: String
    let label: String
    let icon: Icon?

    init?(payload: [String: Any]) {
      guard
        let id = payload["id"] as? String,
        let label = payload["label"] as? String
      else {
        return nil
      }

      self.id = id
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

  let title: String
  let leadingAction: Action?
  let trailingActions: [Action]

  init?(payload: [String: Any]) {
    guard let title = payload["title"] as? String else { return nil }

    self.title = title

    if let leadingPayload = payload["leading_action"] as? [String: Any] {
      leadingAction = Action(payload: leadingPayload)
    } else {
      leadingAction = nil
    }

    if let trailingPayloads = payload["trailing_actions"] as? [[String: Any]] {
      let actions = trailingPayloads.compactMap(Action.init(payload:))
      guard actions.count == trailingPayloads.count else { return nil }
      trailingActions = actions
    } else {
      trailingActions = []
    }
  }
}
