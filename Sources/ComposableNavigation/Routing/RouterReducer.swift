import ComposableArchitecture
import FoundationExtensions

extension ReducerProtocol where
  State: RoutableState,
  Action: RoutableAction,
  State.Route == Action.Route
{
  @inlinable
  public func routing() -> some ReducerProtocol<State, Action> {
    CombineReducers {
      self
      Scope(
        state: \State.currentRoute,
        action: /Action.router,
        _RoutingReducer.init
      )
    }
  }
}

@usableFromInline
struct _RoutingReducer<
  Route: Hashable
>: ReducerProtocol {
  @usableFromInline
  typealias State = Route

  @usableFromInline
  typealias Action = RoutingAction<Route>

  @inlinable
  public init() {}

  @inlinable
  public func reduce(
    into state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
    case let .navigate(to: newRoute):
      state = newRoute
      return .none
    }
  }
}
