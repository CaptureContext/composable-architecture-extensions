import ComposableArchitecture
import Foundation

public protocol ModalStateProtocol<State> {
  associatedtype State
  var state: State { get set }
  var isHidden: Bool { get set }
}

extension ModalStateProtocol where State: Identifiable {
  public typealias ID = State.ID

  @inlinable
  public var id: State.ID { state.id }
}

@dynamicMemberLookup
public struct Modal<State>: ModalStateProtocol {
  public var state: State
  public var isHidden: Bool = true

  @inlinable
  public init(state: State, isHidden: Bool = true) {
    self.state = state
    self.isHidden = isHidden
  }

  @inlinable
  public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
    state[keyPath: keyPath]
  }

  @inlinable
  public subscript<Value>(dynamicMember keyPath: WritableKeyPath<State, Value>) -> Value {
    get { state[keyPath: keyPath] }
    set { state[keyPath: keyPath] = newValue }
  }
}

extension Modal: Identifiable where State: Identifiable {}
extension Modal: Equatable where State: Equatable {}
extension Modal: Hashable where State: Hashable {}
extension Modal: Codable where State: Codable {}

extension Modal where State: ExpressibleByNilLiteral {
  @inlinable
  public init(isHidden: Bool = true) {
    self.init(state: nil, isHidden: isHidden)
  }
}
