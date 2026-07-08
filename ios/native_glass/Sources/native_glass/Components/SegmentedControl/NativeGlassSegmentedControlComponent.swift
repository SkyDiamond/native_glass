import UIKit

final class NativeGlassSegmentedControlComponent: NSObject, NativeGlassComponent {
  private let segmentedControl: UISegmentedControl
  private let eventSink: NativeGlassEventSink
  private var props: NativeGlassSegmentedControlProps?

  var rootView: UIView {
    return segmentedControl
  }

  init(
    frame: CGRect,
    props: [String: Any],
    eventSink: NativeGlassEventSink
  ) {
    segmentedControl = UISegmentedControl(frame: frame)
    self.eventSink = eventSink
    self.props = NativeGlassSegmentedControlProps(payload: props)
    super.init()

    segmentedControl.backgroundColor = .clear
    segmentedControl.addTarget(
      self,
      action: #selector(handleSelectionChanged(_:)),
      for: .valueChanged
    )
    applyProps(rebuildSegments: true)
  }

  func update(props nextProps: [String: Any], diff: [String: Any]) {
    guard let next = NativeGlassSegmentedControlProps(payload: nextProps) else {
      return
    }

    let previousCount = props?.segments.count
    props = next
    applyProps(rebuildSegments: previousCount != next.segments.count)
  }

  func dispose() {
    segmentedControl.removeTarget(nil, action: nil, for: .allEvents)
    segmentedControl.removeAllSegments()
  }

  private func applyProps(rebuildSegments: Bool) {
    guard let props else {
      segmentedControl.removeAllSegments()
      return
    }

    if rebuildSegments || segmentedControl.numberOfSegments != props.segments.count {
      rebuildSegmentsFromProps(props)
    } else {
      updateSegmentsInPlace(props)
    }

    let clampedIndex = min(max(props.selectedIndex, 0), props.segments.count - 1)
    if segmentedControl.selectedSegmentIndex != clampedIndex {
      segmentedControl.selectedSegmentIndex = clampedIndex
    }
  }

  private func rebuildSegmentsFromProps(_ props: NativeGlassSegmentedControlProps) {
    segmentedControl.removeAllSegments()

    for (index, segment) in props.segments.enumerated() {
      if let image = segment.icon?.image() {
        segmentedControl.insertSegment(with: image, at: index, animated: false)
      } else {
        segmentedControl.insertSegment(withTitle: segment.label, at: index, animated: false)
      }
      segmentedControl.setTitle(segment.label, forSegmentAt: index)
    }
  }

  private func updateSegmentsInPlace(_ props: NativeGlassSegmentedControlProps) {
    for (index, segment) in props.segments.enumerated() {
      if let image = segment.icon?.image() {
        segmentedControl.setImage(image, forSegmentAt: index)
      } else {
        segmentedControl.setImage(nil, forSegmentAt: index)
      }
      segmentedControl.setTitle(segment.label, forSegmentAt: index)
    }
  }

  @objc private func handleSelectionChanged(_ sender: UISegmentedControl) {
    eventSink.send(
      "onSegmentSelected",
      arguments: ["index": sender.selectedSegmentIndex]
    )
  }
}
