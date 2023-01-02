import ComposableArchitecture
import ComposableNavigation
import XCTest

final class ModalTests: XCTestCase {
  func testDefault() {
    struct DerivedFeature: ReducerProtocol {
      struct State: Equatable {
        var value: Int = 0
      }

      enum Action: Equatable {
        case increment, decrement
      }

      func reduce(
        into state: inout State,
        action: Action
      ) -> EffectTask<Action> {
        switch action {
        case .increment:
          state.value += 1
          return .none

        case .decrement:
          state.value -= 1
          return .none
        }
      }
    }

    struct RootFeature: ReducerProtocol {
      struct State: Equatable {
        var derived: Modal<DerivedFeature.State> = .init(state: .init())
      }

      enum Action: Equatable {
        case derived(ModalAction<DerivedFeature.Action>)
      }

      var body: some ReducerProtocol<State, Action> {
        Scope(
          state: \State.derived,
          action: /Action.derived
        ) {
          DerivedFeature().modal()
        }
      }
    }
    
    let store = TestStore(
      initialState: .init(),
      reducer: RootFeature()
    )
    
    store.send(.derived(.present)) { state in
      state.derived.isHidden = false
    }
    
    store.send(.derived(.action(.increment))) { state in
      state.derived.value += 1
    }
    
    store.send(.derived(.dismiss)) { state in
      state.derived.isHidden = true
    }
    
    store.send(.derived(.action(.decrement))) { state in
      state.derived.value -= 1
    }
    
    store.send(.derived(.toggle))
    store.receive(.derived(.present)) { state in
      state.derived.isHidden = false
    }
  }
  
  func testOptional() {
      struct DerivedFeature: ReducerProtocol {
        struct State: Equatable {
          var value: Int = 0
        }

        enum Action: Equatable {
          case increment, decrement
        }

        func reduce(
          into state: inout State,
          action: Action
        ) -> EffectTask<Action> {
          switch action {
          case .increment:
            state.value += 1
            return .none

          case .decrement:
            state.value -= 1
            return .none
          }
        }
      }

    struct RootFeature: ReducerProtocol {
      struct State: Equatable {
        @BindableState
        var derived: DerivedFeature.State?
      }

      enum Action: Equatable, BindableAction {
        case derived(ModalAction<DerivedFeature.Action>)
        case binding(BindingAction<State>)
      }

      var body: some ReducerProtocol<State, Action> {
        CombineReducers {
          BindingReducer()
          Scope(
            state: \State.derived,
            action: /Action.derived
          ) {
            DerivedFeature()
              .stateBasedModal { .init() }
          }
        }
      }
    }
    
    let store = TestStore(
      initialState: .init(),
      reducer: RootFeature()
    )
    
    do {
      store.send(.derived(.present)) { state in
        state.derived = .init()
      }

      store.send(.derived(.action(.increment))) { state in
        state.derived?.value += 1
      }
    }

    do {
      store.send(.binding(.set(\.$derived, .init(value: 10)))) { state in
        state.derived?.value = 10
      }

      store.send(.derived(.present))
    }

    do {
      store.send(.binding(.set(\.$derived, nil))) { state in
        state.derived = nil
      }

      store.send(.derived(.dismiss))
    }
    
    do {
      store.send(.derived(.dismiss))

      // Pointfree removed "disable nil warnings" feature
      // from ifLet/scope stores etc. so there is no way
      // to allow you to don't care about redundant actions 😢
      // Maybe we'll add a workaround later, or just stick
      // with the main approach... (to be discussed)

      // store.send(.derived(.action(.decrement)))

      store.send(.derived(.toggle))

      store.receive(.derived(.present)) { state in
        state.derived = .init()
      }
    }
  }
  
  func testDismissOn() {
    struct DerivedFeature: ReducerProtocol {
      struct State: Equatable {
        var value: Int = 0
      }

      enum Action: Equatable {
        case increment, decrement, close
      }

      func reduce(
        into state: inout State,
        action: Action
      ) -> EffectTask<Action> {
        switch action {
        case .increment:
          state.value += 1
          return .none

        case .decrement:
          state.value -= 1
          return .none

        default:
          return .none
        }
      }
    }

    struct RootFeature: ReducerProtocol {
      struct State: Equatable {
        var derived: DerivedFeature.State?
      }

      enum Action: Equatable {
        case derived(ModalAction<DerivedFeature.Action>)
      }

      var body: some ReducerProtocol<State, Action> {
        Scope(
          state: \State.derived,
          action: /Action.derived
        ) {
          DerivedFeature()
            .stateBasedModal { .init() }
            .dismissOn(.close)
        }
      }
    }
    
    let store = TestStore(
      initialState: .init(),
      reducer: RootFeature()
    )
    
    do {
      store.send(.derived(.present)) { state in
        state.derived = .init()
      }

      store.send(.derived(.action(.increment))) { state in
        state.derived?.value += 1
      }
    }
    
    do {
      store.send(.derived(.dismiss)) { state in
        state.derived = nil
      }


      // Pointfree removed "disable nil warnings" feature
      // from ifLet/scope stores etc. so there is no way
      // to allow you to don't care about redundant actions 😢
      // Maybe we'll add a workaround later, or just stick
      // with the main approach... (to be discussed)

      // store.send(.derived(.action(.decrement)))
    }
    
    do {
      store.send(.derived(.toggle))
      store.receive(.derived(.present)) { state in
        state.derived = .init()
      }
    }
    
    do {
      store.send(.derived(.action(.close)))
      store.receive(.derived(.dismiss)) { state in
        state.derived = nil
      }
    }
  }
}
