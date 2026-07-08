enum NativeGlassComponentKind: String {
  case button
  case placeholder
  case navigationBar
  case segmentedControl
  case tabBar

  init(rawValue: String?) {
    self = NativeGlassComponentKind(rawValue: rawValue ?? "") ?? .placeholder
  }
}
