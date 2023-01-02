import ComposableArchitecture
import ComposableExtensionsCore
import FoundationExtensions

extension ReducerProtocol {
  @inlinable
  public func presentOn<LocalAction>(_ actions: LocalAction...) -> some ReducerProtocol<State, Action>
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    CombineReducers {
      self
      _PresentOnReducer1(actions: actions)
    }
  }

  @inlinable
  public func presentOn<LocalAction>(_ actions: CaseMarker<LocalAction>...) -> some ReducerProtocol<State, Action>
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    CombineReducers {
      self
      _PresentOnReducer2(actions: actions)
    }
  }
}

@usableFromInline
struct _PresentOnReducer1<State, LocalAction: Equatable>: ReducerProtocol {
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
    return .init(value: .present)
  }
}

@usableFromInline
struct _PresentOnReducer2<State, LocalAction: Equatable>: ReducerProtocol {
  @usableFromInline
  typealias Action = ModalAction<LocalAction>

  @usableFromInline
  var actions: [CaseMarker<LocalAction>]

  @inlinable
  public init(actions: [CaseMarker<LocalAction>]) {
    self.actions = actions
  }

  @inlinable
  func reduce(
    into state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    guard case let .action(action) = action
    else { return .none }

    return actions.contains { $0.matches(action) }
    ? .init(value: .present)
    : .none
  }
}
