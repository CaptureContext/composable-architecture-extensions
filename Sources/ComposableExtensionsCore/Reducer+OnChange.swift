import ComposableArchitecture

extension Reducer {
  public func onChange<LocalState>(
    of localState: @escaping (State) -> LocalState,
    isEqual: @escaping (LocalState, LocalState) -> Bool,
    reduce: @escaping (LocalState, State, Environment) -> Effect<Action, Never>
  ) -> Reducer {
    var previousState: LocalState!

    return .combine(
      Reducer { state, _, _ in
        previousState = localState(state)
        return .none
      },
      self,
      Reducer { state, _, environment in
        let currentState = localState(state)

        guard !isEqual(previousState, currentState) else {
          return .none
        }

        return reduce(previousState, state, environment)
      }
    )
  }

  public func onChange<LocalState: Equatable>(
    of localState: @escaping (State) -> LocalState,
    reduce: @escaping (LocalState, State, Environment) -> Effect<Action, Never>
  ) -> Reducer {
    self.onChange(of: localState, isEqual: ==, reduce: reduce)
  }
}
