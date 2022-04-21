import ComposableExtensionsCore
import XCTest
import FoundationExtensions

final class ReducerTests: XCTestCase {
  func testOnChange() {
    struct State: Equatable {
      var value: Int = 0
      var savedValues: [Int] = []
    }
    
    enum Action: Equatable {
      case setValue(Int)
      case saveValue(Int)
    }
    
    let reducer = Reducer<State, Action, Void> { state, action, _ in
      switch action {
      case let .setValue(value):
        state.value = value
        return .none
        
      case let .saveValue(value):
        state.savedValues.append(value)
        return .none
      }
    }
    
    let savingChangesReducer = reducer.onChange(of: \.value) { old, state, environment in
      return Effect(value: .saveValue(old))
    }
    
    let store = TestStore(
      initialState: State(value: 1),
      reducer: savingChangesReducer,
      environment: ()
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
    struct State: Equatable {
      var value: Int = 0
    }
    
    enum Action: Equatable {
      case setValue(Int)
    }
    
    let reducer = Reducer<State, Action, Void> { state, action, _ in
      switch action {
      case let .setValue(value):
        state.value = value
        return .none
      }
    }
    
    var isLazyReducerInitialized = false
    let lazyReducer = Reducer<State, Action, Void>.lazy {
      isLazyReducerInitialized = true
      return reducer
    }
    
    let store = TestStore(
      initialState: State(),
      reducer: lazyReducer,
      environment: ()
    )
    
    XCTAssertFalse(isLazyReducerInitialized)
    
    store.send(.setValue(10)) { state in
      state.value = 10
    }
    
    XCTAssertTrue(isLazyReducerInitialized)
  }
  
  func testSelfRecursiveReducer() {
    struct Node: Equatable {
      var value: Int = 0
      var children: [Node] = []
    }
    
    indirect enum Action: Equatable {
      case setValue(Int)
      case child(at: Int, Action)
      case addChild
      case removeChild
      case addChildAndSubchild
    }
    
    let reducer = Reducer<
      Node,
      Action,
      Void
    >.recursive { reducer, state, action, environment in
      switch action {
      case let .setValue(value):
        state.value = value
        return .none
        
      case let .child(index, action):
        return reducer.run(&state.children[index], action, environment)
          .map { .child(at: index, $0) }
        
      case .addChild:
        state.children.append(Node())
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
      }
    }
    
    let store = TestStore(
      initialState: Node(),
      reducer: reducer,
      environment: ()
    )
    
    store.send(.addChild) { state in
      state.children.append(Node())
    }
    
    store.send(.child(at: 0, .addChildAndSubchild))
    store.receive(.child(at: 0, .addChild)) { state in
      state.children[0].children.append(Node())
    }
    store.receive(.child(at: 0, .child(at: 0, .addChild))) { state in
      state.children[0].children[0].children.append(Node())
    }
    
    store.send(.child(at: 0, .child(at: 0, .setValue(-1)))) { state in
      state.children[0].children[0].value = -1
    }
    
    store.send(.addChildAndSubchild)
    store.receive(.addChild) { state in
      state.children.append(Node())
    }
    store.receive(.child(at: 1, .addChild)) { state in
      state.children[1].children.append(Node())
    }
    
    store.send(.child(at: 1, .child(at: 0, .setValue(100)))) { state in
      state.children[1].children[0].value = 100
    }
  }
  
  func testMutuallyRecursiveReducers() {
    struct State1: Equatable {
      var value: Int = 0
      
      @Indirect
      var state2: State2?
    }
    
    indirect enum Action1: Equatable {
      case setValue(Int)
      case action2(Action2)
      case pushState2(State2)
      case popState2
    }
    
    struct State2: Equatable {
      var flag: Bool = false
      
      @Indirect
      var state1: State1?
    }
    
    indirect enum Action2: Equatable {
      case setFlag(Bool)
      case action1(Action1)
      case pushState1(State1)
      case popState1
    }
    
    enum Reducers { // simulate global scope
      static func getOptionalReducer1() -> Reducer<State1?, Action1, Void> {
        return reducer1.optional()
      }
      
      static let reducer1 = Reducer<State1, Action1, Void>.combine(
        Reducer.recursive(
          { reducer2.optional() },
          state: \State1.state2,
          action: /Action1.action2,
          environment: {}
        ),
        Reducer { state, action, _ in
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
        }
      )
      
      static let reducer2 = Reducer<State2, Action2, Void>.combine(
        Reducer.recursive(
          getOptionalReducer1,
          state: \State2.state1,
          action: /Action2.action1,
          environment: {}
        ),
        Reducer { state, action, _ in
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
        }
      )
    }
    
    let store = TestStore(
      initialState: State1(),
      reducer: Reducers.reducer1,
      environment: ()
    )
    
    store.send(.setValue(1)) { state in
      state.value = 1
    }
  
    do {
      let _state2 = State2()
      store.send(.pushState2(_state2)) { state in
        state.state2 = _state2
      }
    }
    
    store.send(.action2(.setFlag(true))) { state in
      state.state2?.flag = true
    }
    
    do {
      let _state1 = State1()
      store.send(.action2(.pushState1(_state1))) { state in
        state.state2?.state1 = _state1
      }
    }
    
    
    do {
      let _state2 = State2()
      store.send(.action2(.action1(.pushState2(_state2)))) { state in
        state.state2?.state1?.state2 = _state2
      }
    }
    
    store.send(.action2(.popState1)) { state in
      state.state2?.state1 = nil
    }
  }
}
