import ComposableArchitecture
import ComposableExtensionsCore

extension ReducerProtocol {
  @inlinable
  public func dismissOn(_ actions: Action...) -> some ReducerProtocol<State, Action>
  where Action: RoutableAction, Action: Equatable, Action.Route: ExpressibleByNilLiteral {
    CombineReducers {
      self
      Reduce { state, action in
        guard actions.contains(action)
        else { return .none }
        return .init(value: .router(.dismiss))
      }
    }
  }

  @inlinable
  public func dismissOn(_ paths: CaseMarker<Action>...) -> some ReducerProtocol<State, Action>
  where Action: RoutableAction, Action.Route: ExpressibleByNilLiteral {
    CombineReducers {
      self
      Reduce { state, action in
        return paths.contains { $0.matches(action) }
        ? .init(value: .router(.dismiss))
        : .none
      }
    }
  }
}

