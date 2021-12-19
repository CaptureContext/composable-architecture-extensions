import ComposableArchitecture

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
    Reducer { state, action, environment in
      guard let localAction = toLocalAction.extract(from: action) else { return .none }
      return reducer()
        .run(&state[keyPath: toLocalState], localAction, toLocalEnvironment(environment))
        .map { toLocalAction.embed($0) }
    }
  }
}
