import ComposableArchitecture
import Foundation

public protocol ModalActionProtocol<Action> {
  associatedtype Action
  static func action(_ action: Action) -> Self
  static var present: Self { get }
  static var dismiss: Self { get }
  static var toggle: Self { get }
}

public enum ModalAction<Action>: ModalActionProtocol {
  case action(Action)
  case present
  case dismiss
  case toggle
}

extension ModalAction: Equatable where Action: Equatable {}
extension ModalAction: Hashable where Action: Hashable {}
