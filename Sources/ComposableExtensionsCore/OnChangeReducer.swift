import ComposableArchitecture

extension ReducerProtocol {
  @inlinable
  public func onChange<LocalState>(
    of localState: @escaping (State) -> LocalState,
    isEqual: @escaping (LocalState, LocalState) -> Bool,
    reduce: @escaping (LocalState, State) -> EffectTask<Action>
  ) -> some ReducerProtocol<State, Action> {
    _OnChangeReducer(
      self,
      of: localState,
      isEqual: isEqual,
      reduce: reduce
    )
  }

  @inlinable
  public func onChange<LocalState: Equatable>(
    of localState: @escaping (State) -> LocalState,
    reduce: @escaping (LocalState, State) -> EffectTask<Action>
  ) -> some ReducerProtocol<State, Action> {
    _OnChangeReducer(
      self,
      of: localState,
      isEqual: ==,
      reduce: reduce
    )
  }
}

@usableFromInline
struct _OnChangeReducer<Wrapped: ReducerProtocol>: ReducerProtocol {
  @usableFromInline
  typealias State = Wrapped.State

  @usableFromInline
  typealias Action = Wrapped.Action

  @usableFromInline
  var reducer: Reduce<State, Action>

  @inlinable
  public init<LocalState>(
    _ reducer: Wrapped,
    of localState: @escaping (State) -> LocalState,
    isEqual: @escaping (LocalState, LocalState) -> Bool,
    reduce: @escaping (LocalState, State) -> EffectTask<Action>
  ) {
    var previousState: LocalState?
    self.reducer = Reduce(CombineReducers {
      Reduce { state, _ in
        previousState = localState(state)
        return .none
      }
      reducer
      Reduce { state, _ in
        let currentState = localState(state)

        guard
          let previousState,
          !isEqual(previousState, currentState)
        else { return .none }

        return reduce(previousState, state)
      }
    })
  }

  @inlinable
  public var body: some ReducerProtocol<State, Action> {
    reducer
  }
}
