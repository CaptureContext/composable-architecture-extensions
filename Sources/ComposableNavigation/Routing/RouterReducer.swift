import ComposableArchitecture
import FoundationExtensions

extension Reducer where State: Hashable, Action == RoutingAction<State>{
  public static func router() -> Reducer {
    Reducer { currentRoute, action, environment in
      switch action {
      case let .navigate(to: newRoute):
        currentRoute = newRoute
        return .none
      }
    }
  }
}

extension Reducer where State: RoutableState, Action == State.RoutingAction {
  @available(*, deprecated, message: "Use reducer.routing() instead")
  public static func router() -> Reducer {
    return Reducer<State.Route, Action, Void>.router()
      .pullback(
        state: \.currentRoute,
        action: /.self,
        environment: const(())
      )
  }
}

extension Reducer {
  public func routing<Route: Hashable>(
    state toLocalState: WritableKeyPath<State, Route>,
    action toLocalAction: CasePath<Action, RoutingAction<Route>>
  ) -> Reducer {
    .combine(
      self,
      Reducer<Route, RoutingAction<Route>, Void>.router()
        .pullback(
          state: toLocalState,
          action: toLocalAction,
          environment: const(())
        )
    )
  }
}

extension Reducer where State: RoutableState {
  public func routing(
    action: CasePath<Action, State.RoutingAction>
  ) -> Reducer {
    return routing(state: \.currentRoute, action: action)
  }
}


extension Reducer where
  State: RoutableState,
  Action: RouterAction,
  State.Route == Action.Route
{
  public func routing() -> Reducer {
    return routing(
      state: \State.currentRoute,
      action: /Action.router
    )
  }
}
