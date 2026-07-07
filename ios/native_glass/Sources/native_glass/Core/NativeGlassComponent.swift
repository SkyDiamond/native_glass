import UIKit

protocol NativeGlassComponent: AnyObject {
  var rootView: UIView { get }

  func update(props: [String: Any], diff: [String: Any])
  func dispose()
}
