import ComposableArchitecture
import ComposableExtensionsCore
import FoundationExtensions

extension ReducerProtocol {
  @inlinable
  public func dismissOn<LocalAction>(_ actions: LocalAction...) -> some ReducerProtocol<State, Action>
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    CombineReducers {
      self
      _DismissOnReducer1(actions: actions)
    }
  }

  @inlinable
  public func dismissOn<LocalAction>(_ actions: CaseMarker<LocalAction>...) -> some ReducerProtocol<State, Action>
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    CombineReducers {
      self
      _DismissOnReducer2(actions: actions)
    }
  }
}

@usableFromInline
struct _DismissOnReducer1<State, LocalAction: Equatable>: ReducerProtocol {
  @usableFromInline
  typealias Action = ModalAction<LocalAction>

  @usableFromInline
  var actions: [LocalAction]

  @inlinable
  public init(actions: [LocalAction]) {
    self.actions = actions
  }

  @inlinable
  public func reduce(
    into state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    guard
      case let .action(action) = action,
      actions.contains(action)
    else { return .none }
    return .init(value: .dismiss)
  }
}

@usableFromInline
struct _DismissOnReducer2<State, LocalAction: Equatable>: ReducerProtocol {
  @inlinable
  public init(actions: [CaseMarker<LocalAction>]) {
    self.actions = actions
  }

  @usableFromInline
  typealias Action = ModalAction<LocalAction>

  @usableFromInline
  var actions: [CaseMarker<LocalAction>]

  @inlinable
  func reduce(
    into state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    guard case let .action(action) = action
    else { return .none }

    return actions.contains { $0.matches(action) }
    ? .init(value: .dismiss)
    : .none
  }
}
