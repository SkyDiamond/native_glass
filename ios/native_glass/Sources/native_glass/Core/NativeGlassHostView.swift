import Flutter
import UIKit

final class NativeGlassHostView: NSObject, FlutterPlatformView {
  private static let supportedSchemaVersion = 1

  private let containerView: UIView
  private let channel: FlutterMethodChannel
  private var component: NativeGlassComponent?
  private var eventSink: NativeGlassEventSink?
  private var isDartHandlerReady = false
  private var pendingProtocolErrors: [String] = []

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
    let eventSink = NativeGlassEventSink(channel: channel)
    self.eventSink = eventSink

    if Self.schemaVersion(in: payload) == Self.supportedSchemaVersion {
      let kind = NativeGlassComponentKind(
        rawValue: payload?["component"] as? String
      )
      let props = payload?["props"] as? [String: Any] ?? [:]
      component = makeComponent(kind: kind, frame: frame, props: props, eventSink: eventSink)
    } else {
      component = makePlaceholder(frame: frame, eventSink: eventSink)
      reportProtocolError("Unsupported native_glass schema_version.")
    }

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
    case .button:
      return NativeGlassButtonComponent(
        frame: frame,
        props: props,
        eventSink: eventSink
      )
    case .placeholder:
      return NativeGlassPlaceholderComponent(
        frame: frame,
        props: props,
        eventSink: eventSink
      )
    case .navigationBar:
      return NativeGlassNavigationBarComponent(
        frame: frame,
        props: props,
        eventSink: eventSink
      )
    case .segmentedControl:
      return NativeGlassSegmentedControlComponent(
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

  private func makePlaceholder(
    frame: CGRect,
    eventSink: NativeGlassEventSink
  ) -> NativeGlassComponent {
    return NativeGlassPlaceholderComponent(
      frame: frame,
      props: [:],
      eventSink: eventSink
    )
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
    case "ready":
      isDartHandlerReady = true
      flushPendingProtocolErrors()
      result(nil)
    case "updateProps":
      guard let payload = call.arguments as? [String: Any] else {
        result(FlutterError(code: "invalid_args", message: "Expected update payload.", details: nil))
        return
      }
      guard Self.schemaVersion(in: payload) == Self.supportedSchemaVersion else {
        replaceWithPlaceholder(reason: "Unsupported native_glass update schema_version.")
        result(nil)
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
    pendingProtocolErrors.removeAll()
    isDartHandlerReady = false
    component?.dispose()
    component = nil
  }

  private func replaceWithPlaceholder(reason: String) {
    let oldRootView = component?.rootView
    component?.dispose()
    oldRootView?.removeFromSuperview()

    guard let eventSink else {
      component = nil
      return
    }

    component = makePlaceholder(frame: containerView.bounds, eventSink: eventSink)
    attachComponent()
    reportProtocolError(reason)
  }

  private func reportProtocolError(_ message: String) {
    NSLog("[NativeGlass] %@", message)
    if isDartHandlerReady {
      eventSink?.send("onProtocolError", arguments: ["message": message])
    } else {
      pendingProtocolErrors.append(message)
    }
  }

  private func flushPendingProtocolErrors() {
    guard isDartHandlerReady else { return }
    let messages = pendingProtocolErrors
    pendingProtocolErrors.removeAll()
    for message in messages {
      eventSink?.send("onProtocolError", arguments: ["message": message])
    }
  }

  private static func schemaVersion(in payload: [String: Any]?) -> Int? {
    return payload?["schema_version"] as? Int
  }
}
