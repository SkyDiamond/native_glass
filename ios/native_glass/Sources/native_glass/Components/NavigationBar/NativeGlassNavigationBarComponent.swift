import UIKit

final class NativeGlassNavigationBarComponent: NSObject, NativeGlassComponent {
  private let navigationBar: UINavigationBar
  private let eventSink: NativeGlassEventSink
  private var props: NativeGlassNavigationBarProps?
  private var actionIdsByTag: [Int: String] = [:]

  var rootView: UIView {
    return navigationBar
  }

  init(
    frame: CGRect,
    props: [String: Any],
    eventSink: NativeGlassEventSink
  ) {
    navigationBar = UINavigationBar(frame: frame)
    self.eventSink = eventSink
    self.props = NativeGlassNavigationBarProps(payload: props)
    super.init()

    navigationBar.backgroundColor = .clear
    navigationBar.isTranslucent = true
    configureAppearance()
    applyProps()
  }

  func update(props nextProps: [String: Any], diff: [String: Any]) {
    guard let next = NativeGlassNavigationBarProps(payload: nextProps) else {
      return
    }

    props = next
    applyProps()
  }

  func dispose() {
    navigationBar.setItems([], animated: false)
    actionIdsByTag.removeAll()
  }

  private func configureAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = .clear
    appearance.shadowColor = .clear
    appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)

    navigationBar.standardAppearance = appearance
    navigationBar.compactAppearance = appearance
    if #available(iOS 15.0, *) {
      navigationBar.scrollEdgeAppearance = appearance
      navigationBar.compactScrollEdgeAppearance = appearance
    }
  }

  private func applyProps() {
    guard let props else {
      navigationBar.setItems([], animated: false)
      actionIdsByTag.removeAll()
      return
    }

    actionIdsByTag.removeAll()
    let item = UINavigationItem(title: props.title)

    if let leadingAction = props.leadingAction {
      item.leftBarButtonItem = makeBarButtonItem(action: leadingAction, tag: 0)
    }

    item.rightBarButtonItems = props.trailingActions.enumerated().map {
      index,
      action in
      makeBarButtonItem(action: action, tag: index + 1)
    }

    navigationBar.setItems([item], animated: false)
  }

  private func makeBarButtonItem(
    action: NativeGlassNavigationBarProps.Action,
    tag: Int
  ) -> UIBarButtonItem {
    actionIdsByTag[tag] = action.id

    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    button.tag = tag
    button.accessibilityLabel = action.label
    button.addTarget(
      self,
      action: #selector(handleAction(_:)),
      for: .touchUpInside
    )
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
      button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
    ])

    if let image = action.icon?.image() {
      button.setImage(
        image.withRenderingMode(.alwaysTemplate),
        for: .normal
      )
    } else {
      button.setTitle(action.label, for: .normal)
    }

    return UIBarButtonItem(customView: button)
  }

  @objc private func handleAction(_ sender: UIButton) {
    guard let id = actionIdsByTag[sender.tag] else { return }
    eventSink.send("onActionSelected", arguments: ["id": id])
  }
}
