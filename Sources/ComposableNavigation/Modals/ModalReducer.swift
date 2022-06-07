import ComposableArchitecture
import FoundationExtensions

extension Reducer {
  public func modal() -> Reducer<
    Modal<State>,
    ModalAction<Action>,
    Environment
  > {
    .combine(
      self.pullback(
        state: \Modal<State>.state,
        action: /ModalAction<Action>.action,
        environment: { $0 }
      ),
      Reducer.modal()
    )
  }
  
  public func modal(
    _ staticStateForPresent: State,
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> Reducer<
    State?,
    ModalAction<Action>,
    Environment
  > {
    .combine(
      self.optional(
        file: file,
        line: line
      ).pullback(
        state: \.self,
        action: /ModalAction<Action>.action,
        environment: { $0 }
      ),
      Reducer.modal(staticStateForPresent)
    )
  }
}

extension Reducer {
  public static func modal<LocalState, LocalAction>(
    state toLocalState: WritableKeyPath<State, Modal<LocalState>>,
    action toLocalAction: CasePath<Action, ModalAction<LocalAction>>
  ) -> Reducer {
    return Reducer<LocalState, LocalAction, Environment>.modal().pullback(
      state: toLocalState,
      action: toLocalAction,
      environment: { $0 }
    )
  }
  
  public static func modal<LocalState, LocalAction>(
    _ staticStateForPresent: LocalState,
    state toLocalState: WritableKeyPath<State, LocalState?>,
    action toLocalAction: CasePath<Action, ModalAction<LocalAction>>
  ) -> Reducer {
    return Reducer<LocalState, LocalAction, Environment>.modal(staticStateForPresent)
      .pullback(
        state: toLocalState,
        action: toLocalAction,
        environment: { $0 }
      )
  }
}

extension Reducer {
  public static func modal() -> Reducer<
    Modal<State>,
    ModalAction<Action>,
    Environment
  > {
    return Reducer<
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
  }
  
  public static func modal(
    _ staticStateForPresent: State
  ) -> Reducer<
    State?,
    ModalAction<Action>,
    Environment
  > {
    return Reducer<
      State?,
      ModalAction<Action>,
      Environment
    > { state, action, _ in
      switch action {
      case .present:
        state = staticStateForPresent
        return .none
        
      case .dismiss:
        state = nil
        return .none
        
      case .toggle:
        return Effect(value: state.isNotNil ? .dismiss : .present)
        
      case .action:
        return .none
      }
    }
  }
}
