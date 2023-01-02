import ComposableArchitecture
import FoundationExtensions

extension ReducerProtocol {
  @inlinable
  public func modal() -> some ReducerProtocol<
    Modal<State>,
    ModalAction<Action>
  > {
    CombineReducers {
      Scope(
        state: \Modal<State>.state,
        action: /ModalAction<Action>.action
      ) {
        self
      }
      _ModalReducer1()
    }
  }

  @inlinable
  public func stateBasedModal(
    _ stateForPresent: @escaping () -> State
  ) -> some ReducerProtocol<
    State?,
    ModalAction<Action>
  >  {
    _StateBasedModalReducer(stateForPresent) {
      self
    }
  }
}

@usableFromInline
struct _ModalReducer1<LocalState, LocalAction>: ReducerProtocol {
  @usableFromInline
  typealias State = Modal<LocalState>

  @usableFromInline
  typealias Action = ModalAction<LocalAction>

  @usableFromInline
  typealias _Body = Never

  @inlinable
  public init() {}

  @inlinable
  public func reduce(
    into state: inout State,
    action: Action
  ) -> EffectTask<Action> {
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



@usableFromInline
struct _ModalReducer2<LocalState, LocalAction>: ReducerProtocol {
  @usableFromInline
  typealias State = Modal<LocalState>

  @usableFromInline
  typealias Action = ModalAction<LocalAction>

  @usableFromInline
  typealias _Body = Never

  @inlinable
  public init() {}

  @inlinable
  public func reduce(
    into state: inout State,
    action: Action
  ) -> EffectTask<Action> {
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

@usableFromInline
struct _StateBasedModalReducer<Content: ReducerProtocol>: ReducerProtocol {

  /// Initializes a reducer that combines all of the reducers in the given build block.
  ///
  /// - Parameter build: A reducer builder.
  @inlinable
  public init(
    _ stateForPresent: @escaping () -> State,
    @ReducerBuilderOf<Content> _ build: () -> Content
  ) {
    self.stateForPresent = stateForPresent
    self.content = build()
  }

  @usableFromInline
  typealias State = Content.State?

  @usableFromInline
  typealias Action = ModalAction<Content.Action>

  @usableFromInline
  @Reference
  var hadState: Bool?

  @usableFromInline
  var stateForPresent: () -> State

  @usableFromInline
  var content: Content

  @inlinable
  public var body: some ReducerProtocol<State, Action> {
    CombineReducers {
      Reduce { state, _ in
        hadState = state.isNotNil // save previous state
        return .none
      }
      Scope(
        state: \.self,
        action: /Action.action,
        { content.optional() }
      )
      Reduce { state, action in
        let hasState = state.isNotNil // get current state

        switch action {
        case .present:
          if !hasState {
            state = stateForPresent()
          }
          return .none

        case .dismiss:
          state = nil
          return .none

        case .toggle:
          return .init(
            value: hasState ? .dismiss : .present
          )

        case .action:
          switch (hadState, hasState) {
          case (true, false):
            return .init(value: .dismiss)
          case (false, true):
            return .init(value: .present)
          default:
            return .none
          }
        }
      }
    }
  }
}
