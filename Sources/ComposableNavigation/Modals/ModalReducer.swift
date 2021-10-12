import ComposableArchitecture

extension Reducer {
  public func modal()
  -> Reducer<Modal<State>, ModalAction<Action>, Environment> {
    .combine(
      self.pullback(
        state: \Modal<State>.state,
        action: /ModalAction<Action>.action,
        environment: { $0 }
      ),
      Reducer<
        Modal<State>,
        ModalAction<Action>,
        Environment
      > { state, action, _ in
        switch action {
        case .present:
          state.isHidden = false
          return .none

        case .dismiss:
          state.isHidden = true
          return .none

        case .toggle:
          return Effect(value: state.isHidden ? .present : .dismiss)

        case .action:
          return .none
        }
      }
    )
  }
}
