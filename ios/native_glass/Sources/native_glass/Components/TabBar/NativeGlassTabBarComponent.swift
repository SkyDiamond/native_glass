import UIKit

final class NativeGlassTabBarComponent: NSObject, NativeGlassComponent, UITabBarControllerDelegate {
  private let controller: UITabBarController
  private let eventSink: NativeGlassEventSink
  private var props: NativeGlassTabBarProps?
  private var currentAppearanceIsDark = false

  var rootView: UIView {
    return controller.view
  }

  init(
    frame: CGRect,
    props: [String: Any],
    eventSink: NativeGlassEventSink
  ) {
    controller = UITabBarController()
    self.eventSink = eventSink
    self.props = NativeGlassTabBarProps(payload: props)
    super.init()

    controller.delegate = self
    controller.view.frame = frame
    controller.view.backgroundColor = .clear
    controller.view.isOpaque = false
    configureAppearance()
    rebuildItems()
  }

  func update(props nextProps: [String: Any], diff: [String: Any]) {
    guard let next = NativeGlassTabBarProps(payload: nextProps) else {
      return
    }

    let previousCount = props?.destinations.count
    props = next

    if previousCount != next.destinations.count {
      rebuildItems()
      return
    }

    updateItemsInPlace()
    updateSelectedIndex()
  }

  func dispose() {
    controller.delegate = nil
    controller.setViewControllers([], animated: false)
  }

  private func configureAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = .clear
    appearance.shadowColor = .clear
    appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)

    let itemAppearance = UITabBarItemAppearance()
    itemAppearance.normal.iconColor = .systemGray
    itemAppearance.selected.iconColor = .tintColor

    let labelFont = UIFont.systemFont(ofSize: 10, weight: .medium)
    itemAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.secondaryLabel,
      .font: labelFont,
    ]
    itemAppearance.selected.titleTextAttributes = [
      .foregroundColor: UIColor.label,
      .font: labelFont,
    ]

    appearance.stackedLayoutAppearance = itemAppearance
    appearance.inlineLayoutAppearance = itemAppearance
    appearance.compactInlineLayoutAppearance = itemAppearance

    controller.tabBar.standardAppearance = appearance
    if #available(iOS 15.0, *) {
      controller.tabBar.scrollEdgeAppearance = appearance
    }
    controller.tabBar.isTranslucent = true
  }

  private func rebuildItems() {
    guard let props else {
      controller.setViewControllers([], animated: false)
      return
    }

    let viewControllers = props.destinations.enumerated().map { index, destination in
      let viewController = UIViewController()
      viewController.view.backgroundColor = .clear
      viewController.tabBarItem = makeItem(index: index, destination: destination)
      return viewController
    }

    controller.setViewControllers(viewControllers, animated: false)
    updateSelectedIndex()
  }

  private func updateItemsInPlace() {
    guard
      let props,
      let viewControllers = controller.viewControllers
    else {
      return
    }

    for viewController in viewControllers {
      let index = viewController.tabBarItem.tag
      guard index >= 0 && index < props.destinations.count else { continue }
      let destination = props.destinations[index]
      viewController.tabBarItem.title = destination.label
      viewController.tabBarItem.image = destination.icon.image()
      viewController.tabBarItem.selectedImage = selectedImage(for: destination)
      viewController.tabBarItem.badgeValue = destination.badge?.value
    }
  }

  private func updateSelectedIndex() {
    guard let props, let viewControllers = controller.viewControllers else { return }
    let clampedIndex = min(max(props.selectedIndex, 0), viewControllers.count - 1)
    if controller.selectedIndex != clampedIndex {
      controller.selectedIndex = clampedIndex
    }
  }

  private func makeItem(index: Int, destination: NativeGlassTabBarProps.Destination) -> UITabBarItem {
    let item = UITabBarItem(
      title: destination.label,
      image: destination.icon.image(),
      tag: index
    )
    item.selectedImage = selectedImage(for: destination)
    item.badgeValue = destination.badge?.value
    return item
  }

  private func selectedImage(for destination: NativeGlassTabBarProps.Destination) -> UIImage? {
    guard let selectedIcon = destination.selectedIcon else { return nil }
    let image = selectedIcon.image()
    if selectedIcon.usesOriginalRenderingWhenSelected {
      return image?.withRenderingMode(.alwaysOriginal)
    }
    return image
  }

  func tabBarController(
    _ tabBarController: UITabBarController,
    didSelect viewController: UIViewController
  ) {
    let index = viewController.tabBarItem.tag
    eventSink.send("onDestinationSelected", arguments: ["index": index])
  }
}
