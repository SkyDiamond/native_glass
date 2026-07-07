enum NativeGlassComponentKind: String {
  case placeholder
  case tabBar

  init(rawValue: String?) {
    self = NativeGlassComponentKind(rawValue: rawValue ?? "") ?? .placeholder
  }
}
