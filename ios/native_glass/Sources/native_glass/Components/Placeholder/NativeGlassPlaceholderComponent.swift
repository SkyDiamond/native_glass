import UIKit

final class NativeGlassPlaceholderComponent: NativeGlassComponent {
  let rootView: UIView
  private let eventSink: NativeGlassEventSink

  init(
    frame: CGRect,
    props: [String: Any],
    eventSink: NativeGlassEventSink
  ) {
    rootView = UIView(frame: frame)
    rootView.backgroundColor = .clear
    rootView.isOpaque = false
    self.eventSink = eventSink
  }

  func update(props: [String: Any], diff: [String: Any]) {}

  func dispose() {
    _ = eventSink
  }
}
