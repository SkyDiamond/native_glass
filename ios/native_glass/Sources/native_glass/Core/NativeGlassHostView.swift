import Flutter
import UIKit

final class NativeGlassHostView: NSObject, FlutterPlatformView {
  private let containerView: UIView
  private let channel: FlutterMethodChannel
  private var component: NativeGlassComponent?

  init(
    frame: CGRect,
    viewId: Int64,
    args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    containerView = UIView(frame: frame)
    containerView.backgroundColor = .clear
    containerView.isOpaque = false

    channel = FlutterMethodChannel(
      name: "native_glass/view_\(viewId)",
      binaryMessenger: messenger
    )

    super.init()

    let payload = args as? [String: Any]
    let kind = NativeGlassComponentKind(
      rawValue: payload?["component"] as? String
    )
    let props = payload?["props"] as? [String: Any] ?? [:]
    let eventSink = NativeGlassEventSink(channel: channel)
    component = makeComponent(kind: kind, frame: frame, props: props, eventSink: eventSink)
    attachComponent()
    installMethodHandler()
  }

  func view() -> UIView {
    return containerView
  }

  private func makeComponent(
    kind: NativeGlassComponentKind,
    frame: CGRect,
    props: [String: Any],
    eventSink: NativeGlassEventSink
  ) -> NativeGlassComponent {
    switch kind {
    case .placeholder:
      return NativeGlassPlaceholderComponent(
        frame: frame,
        props: props,
        eventSink: eventSink
      )
    case .tabBar:
      return NativeGlassTabBarComponent(
        frame: frame,
        props: props,
        eventSink: eventSink
      )
    }
  }

  private func attachComponent() {
    guard let rootView = component?.rootView else { return }
    rootView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(rootView)
    NSLayoutConstraint.activate([
      rootView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rootView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rootView.topAnchor.constraint(equalTo: containerView.topAnchor),
      rootView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    ])
  }

  private func installMethodHandler() {
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "updateProps":
      guard let payload = call.arguments as? [String: Any] else {
        result(FlutterError(code: "invalid_args", message: "Expected update payload.", details: nil))
        return
      }
      let props = payload["props"] as? [String: Any] ?? [:]
      let diff = payload["diff"] as? [String: Any] ?? [:]
      component?.update(props: props, diff: diff)
      result(nil)
    case "setVisible":
      let payload = call.arguments as? [String: Any]
      containerView.isHidden = !(payload?["visible"] as? Bool ?? true)
      result(nil)
    case "dispose":
      dispose()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func dispose() {
    channel.setMethodCallHandler(nil)
    component?.dispose()
    component = nil
  }
}
