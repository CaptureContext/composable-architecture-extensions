import ComposableArchitecture
import ComposableDependencies
import FoundationExtensions

extension Reducer {
  public static func recursive(
    _ reducer: @escaping (Reducer, inout State, Action, Environment) -> Effect<Action, Never>
  ) -> Reducer {
    var `self`: Reducer!
    self = Reducer { state, action, environment in
      reducer(self, &state, action, environment)
    }
    return self
  }
}

extension Reducer {
  public static func recursive<
    LocalState,
    LocalAction,
    LocalEnvironment
  >(
    _ reducer: @escaping () -> Reducer<LocalState, LocalAction, LocalEnvironment>,
    state toLocalState: WritableKeyPath<State, LocalState>,
    action toLocalAction: CasePath<Action, LocalAction>,
    environment toLocalEnvironment: @escaping (Environment) -> LocalEnvironment
  ) -> Reducer {
    return Reducer<LocalState, LocalAction, LocalEnvironment>
      .lazy(reducer)
      .pullback(
        state: toLocalState,
        action: toLocalAction,
        environment: toLocalEnvironment
      )
  }
}

extension Reducer {
  public static func lazy(_ reducer: @escaping () -> Reducer) -> Reducer {
    var _reducer: Reducer!
    return Reducer { state, action, environment in
      if _reducer.isNil { _reducer = reducer() }
      return _reducer.run(&state, action, environment)
    }
  }
}
