import ComposableArchitecture
import ComposableExtensionsCore

extension Reducer {
  public func stateBasedRouting<LocalState, LocalAction>() -> Reducer
  where State == Modal<LocalState?>, Action == ModalAction<LocalAction> {
    var hadState: Bool? = nil
    return Reducer.combine(
      Reducer { state, _, _ in
        hadState = state.state.isNotNil // save previous state
        return .none
      },
      self, // run reducer
      Reducer { state, action, environment in
        let hasState = state.state.isNotNil // get current state
        
        if case .dismiss = action, hasState { // nil on dismiss
          state.state = nil
          return .none
        }

        guard hasState != hadState else { return .none }
        
        return hasState ? .none : Effect(value: .dismiss) // dismiss on nil
      }
    )
  }
  
  public func dismissOn<LocalAction>(_ actions: LocalAction...) -> Reducer
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    .combine(
      self,
      Reducer { state, action, environment in
        guard
          case let .action(action) = action,
          actions.contains(action)
        else { return .none }
        return Effect(value: .dismiss)
      }
    )
  }

  public func dismissOn<LocalAction>(_ paths: CaseMarker<LocalAction>...) -> Reducer
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    .combine(
      self,
      Reducer { state, action, environment in
        guard case let .action(action) = action else { return .none }
        return paths.contains { $0.matches(action) }
          ? Effect(value: .dismiss)
          : .none
      }
    )
  }

  public func presentOn<LocalAction>(_ actions: LocalAction...) -> Reducer
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    .combine(
      self,
      Reducer { state, action, environment in
        guard
          case let .action(action) = action,
          actions.contains(action)
        else { return .none }
        return Effect(value: .present)
      }
    )
  }

  public func presentOn<LocalAction>(_ paths: CaseMarker<LocalAction>...) -> Reducer
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    .combine(
      self,
      Reducer { state, action, environment in
        guard case let .action(action) = action else { return .none }
        return paths.contains { $0.matches(action) }
          ? Effect(value: .present)
          : .none
      }
    )
  }
}

