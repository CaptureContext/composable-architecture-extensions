import CasePaths

extension CasePath {
  /// Helper function for enum properies
  ///
  /// Usage
  /// ```
  /// enum Enum {
  ///   case a(Int)
  ///   case b(Bool)
  ///
  ///   var a: Int? {
  ///     get { (/Self.a).extract(from: self) }
  ///     set { (/Self.a).ifCaseLetEmbed(newValue, in: &self) }
  ///   }
  ///
  ///   var b: Bool? {
  ///     get { (/Self.b).extract(from: self) }
  ///     set { (/Self.b).ifCaseLetEmbed(newValue, in: &self) }
  ///   }
  /// }
  /// ```
  @inlinable
  public func ifCaseLetEmbed(_ value: Value?, in root: inout Root) {
    guard extract(from: root) != nil, let value = value else { return }
    root = embed(value)
  }
}

// MARK: CasePathValueDetector

public struct CaseMarker<Root> {
  @usableFromInline
  let _matches: (Root) -> Bool

  @inlinable
  public func matches(_ value: Root) -> Bool {
    _matches(value)
  }

  @inlinable
  public init(matches: @escaping (Root) -> Bool) {
    self._matches = matches
  }

  @inlinable
  public init<Value>(
    for casePath: CasePath<Root, Value>
  ) {
    self.init { casePath.extract(from: $0).isNotNil }
  }
}

/// Returns a case path for the given embed function.
///
/// - Note: This operator is only intended to be used with enum cases that have no associated
///   values. Its behavior is otherwise undefined.
/// - Parameter embed: An embed function.
/// - Returns: A case path.
@inlinable
public prefix func / <Root, Value>(
  embed: @escaping (Value) -> Root
) -> CaseMarker<Root> {
  return CaseMarker(for: /embed)
}

/// Returns a case path for the given embed function.
///
/// - Note: This operator is only intended to be used with enum cases that have no associated
///   values. Its behavior is otherwise undefined.
/// - Parameter embed: An embed function.
/// - Returns: A case path.
@inlinable
public prefix func / <Root>(
  case: Root
) -> CaseMarker<Root> {
  return CaseMarker(for: /`case`)
}

