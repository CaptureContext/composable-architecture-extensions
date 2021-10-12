import ComposableArchitecture
import Foundation

public enum ModalAction<Action> {
  case action(Action)
  case present
  case dismiss
  case toggle
}

extension ModalAction: Equatable where Action: Equatable {}
extension ModalAction: Hashable where Action: Hashable {}
