@_spi(Internals) import ComposableArchitecture

extension Store where State: ObservableState {
  public func _scope<ChildState, ChildAction>(
    state: KeyPath<State, ChildState?>,
    action: CaseKeyPath<Action, ChildAction>
  ) -> Store<ChildState?, ChildAction> {
    return self.scope(
      id: self.id(state: state, action: action),
      state: ToState(state),
      action: { action($0) },
      isInvalid: { $0[keyPath: state] == nil }
    )
  }
}

