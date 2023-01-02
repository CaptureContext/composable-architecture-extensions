import ComposableExtensionsCore
import XCTest
import FoundationExtensions

final class ReducerTests: XCTestCase {
  func testOnChange() {
    struct Feature: ReducerProtocol {
      struct State: Equatable {
        var value: Int = 0
        var savedValues: [Int] = []
      }

      enum Action: Equatable {
        case setValue(Int)
        case saveValue(Int)
      }

      func reduce(
        into state: inout State,
        action: Action
      ) -> EffectTask<Action> {
        switch action {
        case let .setValue(value):
          state.value = value
          return .none

        case let .saveValue(value):
          state.savedValues.append(value)
          return .none
        }
      }
    }

    let store = TestStore(
      initialState: .init(value: 1),
      reducer: Feature()
        .onChange(of: \.value) { old, _ in
          return .init(value: .saveValue(old))
        }
    )

    store.send(.setValue(10)) { state in
      state.value = 10
    }

    store.receive(.saveValue(1)) { state in
      state.savedValues.append(1)
    }

    store.send(.setValue(5)) { state in
      state.value = 5
    }

    store.receive(.saveValue(10)) { state in
      state.savedValues.append(10)
    }

    store.send(.setValue(0)) { state in
      state.value = 0
    }

    store.receive(.saveValue(5)) { state in
      state.savedValues.append(5)
    }
  }

  func testLazyReducer() {
    struct ValueSetter: ReducerProtocol {
      static var initCount = 0

      struct State: Equatable {
        var value: Int = 0
      }

      enum Action: Equatable {
        case setValue(Int)
      }

      init() {
        Self.initCount += 1
      }

      func reduce(
        into state: inout State,
        action: Action
      ) -> EffectTask<Action> {
        switch action {
        case let .setValue(value):
          state.value = value
          return .none
        }
      }
    }

    let store = TestStore(
      initialState: ValueSetter.State(),
      reducer: LazyReducer {
        ValueSetter()
      }
    )

    XCTAssertEqual(ValueSetter.initCount, 0)

    store.send(.setValue(10)) { state in
      state.value = 10
    }

    XCTAssertEqual(ValueSetter.initCount, 1)
  }

  func testSelfRecursiveReducer() {
    struct Test: ReducerProtocol {
      struct State: Equatable {
        var value: Int = 0
        var children: [State] = []
      }

      indirect enum Action: Equatable {
        case setValue(Int)
        case child(at: Int, Action)
        case addChild
        case removeChild
        case addChildAndSubchild
      }

      var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
          switch action {
          case let .setValue(value):
            state.value = value
            return .none

          case .addChild:
            state.children.append(State())
            return .none

          case .removeChild:
            _ = state.children.popLast()
            return .none

          case .addChildAndSubchild:
            let index = state.children.count
            return .concatenate(
              Effect(value: .addChild),
              Effect(value: .child(at: index, .addChild))
            )

          default:
            return .none
          }
        }.recursive(
          reducer: self,
          state: \State.children,
          action: /Action.child
        )
      }
    }

    let store = TestStore(
      initialState: .init(),
      reducer: Test()
    )

    store.send(.addChild) { state in
      state.children.append(Test.State())
    }

    store.send(.child(at: 0, .addChildAndSubchild))

    store.receive(.child(at: 0, .addChild)) { state in
      state.children[0].children.append(Test.State())
    }

    store.receive(.child(at: 0, .child(at: 0, .addChild))) { state in
      state.children[0].children[0].children.append(Test.State())
    }

    store.send(.child(at: 0, .child(at: 0, .setValue(-1)))) { state in
      state.children[0].children[0].value = -1
    }

    store.send(.addChildAndSubchild)
    store.receive(.addChild) { state in
      state.children.append(Test.State())
    }
    store.receive(.child(at: 1, .addChild)) { state in
      state.children[1].children.append(Test.State())
    }

    store.send(.child(at: 1, .child(at: 0, .setValue(100)))) { state in
      state.children[1].children[0].value = 100
    }
  }

  func testMutuallyRecursiveReducers() {
    struct Feature1: ReducerProtocol {
      struct State: Equatable {
        var value: Int = 0

        @Indirect
        var state2: Feature2.State?
      }

      indirect enum Action: Equatable {
        case setValue(Int)
        case action2(Feature2.Action)
        case pushState2(Feature2.State)
        case popState2
      }

      var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
          switch action {
          case let .setValue(value):
            state.value = value
            return .none

          case let .pushState2(value):
            state.state2 = value
            return .none

          case .popState2:
            state.state2 = nil
            return .none

          default:
            return .none
          }
        }.ifLet(\.state2, action: /Action.action2) {
          Feature2()
        }
      }
    }

    struct Feature2: ReducerProtocol {
      struct State: Equatable {
        var flag: Bool = false

        @Indirect
        var state1: Feature1.State?
      }

      indirect enum Action: Equatable {
        case setFlag(Bool)
        case action1(Feature1.Action)
        case pushState1(Feature1.State)
        case popState1
      }

      var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
          switch action {
          case let .setFlag(value):
            state.flag = value
            return .none

          case let .pushState1(value):
            state.state1 = value
            return .none

          case .popState1:
            state.state1 = nil
            return .none

          default:
            return .none
          }
        }.ifLet(\.state1, action: /Action.action1) {
          Feature1()
        }
      }
    }

    let store = TestStore(
      initialState: .init(),
      reducer: Feature1()
    )

    store.send(.setValue(1)) { state in
      state.value = 1
    }

    do {
      let _state2 = Feature2.State()
      store.send(.pushState2(_state2)) { state in
        state.state2 = _state2
      }
    }

    store.send(.action2(.setFlag(true))) { state in
      state.state2?.flag = true
    }

    do {
      let _state1 = Feature1.State()
      store.send(.action2(.pushState1(_state1))) { state in
        state.state2?.state1 = _state1
      }
    }


    do {
      let _state2 = Feature2.State()
      store.send(.action2(.action1(.pushState2(_state2)))) { state in
        state.state2?.state1?.state2 = _state2
      }
    }

    store.send(.action2(.popState1)) { state in
      state.state2?.state1 = nil
    }
  }
}
