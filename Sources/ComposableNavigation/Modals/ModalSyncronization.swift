import ComposableArchitecture

extension Reducer {
  public func stateBasedRouting<LocalState, LocalAction>() -> Reducer
  where State == Modal<LocalState?>, Action == ModalAction<LocalAction> {
    var hadState: Bool? = nil
    return Reducer.combine(
      Reducer { state, _, _ in
        hadState = state.state != nil // save previous state
        return .none
      },
      self, // run reducer
      Reducer { state, action, environment in
        let hasState = state.state != nil // get current state
        
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

  public func dismissOn<LocalAction>(_ paths: CasePathValueDetector<LocalAction>...) -> Reducer
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    .combine(
      self,
      Reducer { state, action, environment in
        guard case let .action(action) = action else { return .none }
        return paths.contains { $0.is(action) }
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

  public func presentOn<LocalAction>(_ paths: CasePathValueDetector<LocalAction>...) -> Reducer
  where Action == ModalAction<LocalAction>, LocalAction: Equatable {
    .combine(
      self,
      Reducer { state, action, environment in
        guard case let .action(action) = action else { return .none }
        return paths.contains { $0.is(action) }
          ? Effect(value: .present)
          : .none
      }
    )
  }
}

// MARK: CasePathValueDetector

public struct CasePathValueDetector<Root> {
  private let _detect: (Root) -> Bool

  public func `is`(_ action: Root) -> Bool {
    _detect(action)
  }

  public static func detector<Value>(
    for casePath: CasePath<Root, Value>
  ) -> CasePathValueDetector {
    CasePathValueDetector(_detect: { casePath.extract(from: $0) != nil })
  }
}

/// Returns a case path for the given embed function.
///
/// - Note: This operator is only intended to be used with enum cases that have no associated
///   values. Its behavior is otherwise undefined.
/// - Parameter embed: An embed function.
/// - Returns: A case path.
public prefix func / <Root, Value>(
  embed: @escaping (Value) -> Root
) -> CasePathValueDetector<Root> {
  .detector(for: /embed)
}

/// Returns a case path for the given embed function.
///
/// - Note: This operator is only intended to be used with enum cases that have no associated
///   values. Its behavior is otherwise undefined.
/// - Parameter embed: An embed function.
/// - Returns: A case path.
public prefix func / <Root>(
  case: Root
) -> CasePathValueDetector<Root> {
  .detector(for: /`case`)
}

