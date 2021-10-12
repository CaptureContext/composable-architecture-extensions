import ComposableArchitecture
import Foundation

@dynamicMemberLookup
public struct Modal<State> {
  public init(state: State, isHidden: Bool = true) {
    self.state = state
    self.isHidden = isHidden
  }

  public var state: State
  public var isHidden: Bool = true

  public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
    state[keyPath: keyPath]
  }

  public subscript<Value>(dynamicMember keyPath: WritableKeyPath<State, Value>) -> Value {
    get { state[keyPath: keyPath] }
    set { state[keyPath: keyPath] = newValue }
  }
}

@available(iOS 13, *)
extension Modal: Identifiable where State: Identifiable {
  public var id: State.ID { state.id }
}

extension Modal: Equatable where State: Equatable {}
extension Modal: Hashable where State: Hashable {}
extension Modal: Codable where State: Codable {}

extension Modal where State: ExpressibleByNilLiteral {
  public init(isHidden: Bool = true) {
    self.init(state: nil, isHidden: isHidden)
  }
}
