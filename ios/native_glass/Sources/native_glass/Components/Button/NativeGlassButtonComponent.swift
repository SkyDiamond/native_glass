import UIKit

final class NativeGlassButtonComponent: NSObject, NativeGlassComponent {
  private let button: UIButton
  private let eventSink: NativeGlassEventSink
  private var props: NativeGlassButtonProps?

  var rootView: UIView {
    return button
  }

  init(
    frame: CGRect,
    props: [String: Any],
    eventSink: NativeGlassEventSink
  ) {
    if #available(iOS 15.0, *) {
      if #available(iOS 26.0, *) {
        button = UIButton(configuration: .glass(), primaryAction: nil)
      } else {
        button = UIButton(configuration: .bordered(), primaryAction: nil)
      }
    } else {
      button = UIButton(type: .system)
    }
    self.eventSink = eventSink
    self.props = NativeGlassButtonProps(payload: props)
    super.init()

    button.frame = frame
    button.addTarget(
      self,
      action: #selector(handlePress),
      for: .touchUpInside
    )
    applyProps()
  }

  func update(props nextProps: [String: Any], diff: [String: Any]) {
    guard let next = NativeGlassButtonProps(payload: nextProps) else {
      return
    }

    props = next
    applyProps()
  }

  func dispose() {
    button.removeTarget(nil, action: nil, for: .allEvents)
  }

  private func applyProps() {
    guard let props else {
      button.isEnabled = false
      return
    }

    if #available(iOS 15.0, *) {
      var configuration: UIButton.Configuration
      if #available(iOS 26.0, *) {
        configuration = .glass()
      } else {
        configuration = .bordered()
      }

      configuration.title = props.label
      configuration.cornerStyle = .capsule
      configuration.buttonSize = .large
      button.configuration = configuration
    } else {
      button.setTitle(props.label, for: .normal)
      button.layer.cornerRadius = 12
    }

    button.isEnabled = props.enabled
    button.accessibilityLabel = props.label
  }

  @objc private func handlePress() {
    guard props?.enabled == true else { return }
    eventSink.send("onPressed")
  }
}
