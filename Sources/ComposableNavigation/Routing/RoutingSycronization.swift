import ComposableArchitecture
import ComposableExtensionsCore

extension Reducer {
  public func dismissOn(_ actions: Action...) -> Reducer
  where Action: RouterAction, Action: Equatable, Action.Route: ExpressibleByNilLiteral {
    .combine(
      self,
      Reducer { state, action, environment in
        guard actions.contains(action)
        else { return .none }
        return Effect(value: .router(.dismiss))
      }
    )
  }
  
  public func dismissOn(_ paths: CaseMarker<Action>...) -> Reducer
  where Action: RouterAction, Action.Route: ExpressibleByNilLiteral {
    .combine(
      self,
      Reducer { state, action, environment in
        return paths.contains { $0.matches(action) }
          ? Effect(value: .router(.dismiss))
          : .none
      }
    )
  }
}

