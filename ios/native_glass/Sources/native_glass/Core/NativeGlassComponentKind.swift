enum NativeGlassComponentKind: String {
  case placeholder
  case navigationBar
  case tabBar

  init(rawValue: String?) {
    self = NativeGlassComponentKind(rawValue: rawValue ?? "") ?? .placeholder
  }
}
