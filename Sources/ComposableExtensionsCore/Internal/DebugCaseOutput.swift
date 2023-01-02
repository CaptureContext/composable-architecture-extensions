@usableFromInline
func debugCaseOutput(_ value: Any) -> String {
  return (value as? CustomDebugStringConvertible)?.debugDescription
    ?? "\(typeName(type(of: value)))\(debugCaseOutputHelp(value))"
}

private func debugCaseOutputHelp(_ value: Any) -> String {
  let mirror = Mirror(reflecting: value)
  switch mirror.displayStyle {
  case .enum:
    guard let child = mirror.children.first else {
      let childOutput = "\(value)"
      return childOutput == "\(type(of: value))" ? "" : ".\(childOutput)"
    }
    let childOutput = debugCaseOutputHelp(child.value)
    return ".\(child.label ?? "")\(childOutput.isEmpty ? "" : "(\(childOutput))")"
  case .tuple:
    return mirror.children.map { label, value in
      let childOutput = debugCaseOutputHelp(value)
      return
        "\(label.map { isUnlabeledArgument($0) ? "_:" : "\($0):" } ?? "")\(childOutput.isEmpty ? "" : " \(childOutput)")"
    }
    .joined(separator: ", ")
  default:
    return ""
  }
}

private func isUnlabeledArgument(_ label: String) -> Bool {
  label.firstIndex(where: { $0 != "." && !$0.isNumber }) == nil
}

private func typeName(_ type: Any.Type) -> String {
  var name = _typeName(type, qualified: true)
  if let index = name.firstIndex(of: ".") {
    name.removeSubrange(...index)
  }
  let sanitizedName =
    name
    .replacingOccurrences(
      of: #"<.+>|\(unknown context at \$[[:xdigit:]]+\)\."#,
      with: "",
      options: .regularExpression
    )
  return sanitizedName
}

