import ComposableArchitecture
import Foundation

extension Reducer where State: RoutableState, Action == State.RoutingAction {
  public static func router() -> Reducer {
    Reducer { state, action, environment in
      switch action {
      case let .navigate(to: newRoute):
        state.currentRoute = newRoute
        return .none
      }
    }
  }
}

extension Reducer where State: RoutableState, Action: RouterAction, State.Route == Action.Route {
  public func routing() -> Reducer {
    Reducer.combine(
      self,
      Reducer { state, action, environment in
        guard let routerAction = (/Action.router).extract(from: action)
        else { return .none }

        state.currentRoute = routerAction.route
        return .none
      }
    )
  }
}

extension Reducer where State: RoutableState {
  public func routing(
    action: CasePath<Action, State.RoutingAction>
  ) -> Reducer {
    .combine(
      self,
      Reducer<State, State.RoutingAction, Void>.router()
        .pullback(
          state: \.self,
          action: action,
          environment: { _ in }
        )
    )
  }
}
