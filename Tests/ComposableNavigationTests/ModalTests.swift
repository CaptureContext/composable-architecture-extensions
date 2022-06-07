import ComposableArchitecture
import ComposableNavigation
import XCTest

final class ModalTests: XCTestCase {
  func testDefault() {
    struct RootState: Equatable {
      var derived: Modal<DerivedState> = .init(state: DerivedState())
    }
    
    enum RootAction: Equatable {
      case derived(ModalAction<DerivedAction>)
    }
    
    struct DerivedState: Equatable {
      var value: Int = 0
    }
    
    enum DerivedAction: Equatable {
      case increment, decrement
    }
    
    
    let derivedReducer = Reducer<
      DerivedState,
      DerivedAction,
      Void
    > { state, action, environment in
      switch action {
      case .increment:
        state.value += 1
        return .none
        
      case .decrement:
        state.value -= 1
        return .none
      }
    }
    
    let rootReducer: Reducer<
      RootState,
      RootAction,
      Void
    > = derivedReducer.modal().pullback(
      state: \RootState.derived,
      action: /RootAction.derived,
      environment: { _ in }
    )
    
    let store = TestStore(
      initialState: RootState(),
      reducer: rootReducer,
      environment: ()
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
    struct RootState: Equatable {
      var derived: DerivedState?
    }
    
    enum RootAction: Equatable {
      case derived(ModalAction<DerivedAction>)
    }
    
    struct DerivedState: Equatable {
      var value: Int = 0
    }
    
    enum DerivedAction: Equatable {
      case increment, decrement
    }
    
    let derivedReducer = Reducer<
      DerivedState,
      DerivedAction,
      Void
    > { state, action, environment in
      switch action {
      case .increment:
        state.value += 1
        return .none
        
      case .decrement:
        state.value -= 1
        return .none
      }
    }
    
    let initialDerivedState = DerivedState()
    
    let rootReducer: Reducer<
      RootState,
      RootAction,
      Void
    > = derivedReducer.modal(initialDerivedState).pullback(
      state: \RootState.derived,
      action: /RootAction.derived,
      environment: { _ in }
    )
    
    let store = TestStore(
      initialState: RootState(),
      reducer: rootReducer,
      environment: ()
    )
    
    store.send(.derived(.present)) { state in
      state.derived = initialDerivedState
    }
    
    store.send(.derived(.action(.increment))) { state in
      state.derived?.value += 1
    }
    
    store.send(.derived(.dismiss)) { state in
      state.derived = nil
    }
    
    store.send(.derived(.action(.decrement)))
    
    store.send(.derived(.toggle))
    store.receive(.derived(.present)) { state in
      state.derived = initialDerivedState
    }
  }
  
  func testDismissOn() {
    struct RootState: Equatable {
      var derived: DerivedState?
    }
    
    enum RootAction: Equatable {
      case derived(ModalAction<DerivedAction>)
    }
    
    struct DerivedState: Equatable {
      var value: Int = 0
    }
    
    enum DerivedAction: Equatable {
      case increment, decrement, close
    }
    
    let derivedReducer = Reducer<
      DerivedState,
      DerivedAction,
      Void
    > { state, action, environment in
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
    
    let initialDerivedState = DerivedState()
    
    let rootReducer: Reducer<
      RootState,
      RootAction,
      Void
    > = derivedReducer.modal(initialDerivedState)
    .dismissOn(.close)
    .pullback(
      state: \RootState.derived,
      action: /RootAction.derived,
      environment: { _ in }
    )
    
    let store = TestStore(
      initialState: RootState(),
      reducer: rootReducer,
      environment: ()
    )
    
    store.send(.derived(.present)) { state in
      state.derived = initialDerivedState
    }
    
    store.send(.derived(.action(.increment))) { state in
      state.derived?.value += 1
    }
    
    store.send(.derived(.dismiss)) { state in
      state.derived = nil
    }
    
    store.send(.derived(.action(.decrement)))
    
    store.send(.derived(.toggle))
    store.receive(.derived(.present)) { state in
      state.derived = initialDerivedState
    }
    
    store.send(.derived(.action(.close)))
    store.receive(.derived(.dismiss)) { state in
      state.derived = nil
    }
  }
}
