import ComposableArchitecture
import ComposableNavigation
import XCTest

final class NavigationTests: XCTestCase {
  func testStored() {
    struct RootState: RoutableState, Equatable {
      var derived: DerivedState = .init()
      var currentRoute: RootRoute? = .none
    }
    
    enum RootRoute: Hashable {
      case derived
    }
    
    enum RootAction: RouterAction, Equatable {
      case derived(DerivedAction)
      case router(RoutingAction<RootRoute?>)
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
    > = derivedReducer.pullback(
      state: \RootState.derived,
      action: /RootAction.derived,
      environment: { _ in }
    ).routing()
    
    let store = TestStore(
      initialState: RootState(),
      reducer: rootReducer,
      environment: ()
    )
    
    store.send(.navigate(to: .derived)) { state in
      state.currentRoute = .derived
    }
    
    store.send(.derived(.increment)) { state in
      state.derived.value += 1
    }
    
    store.send(.router(.dismiss)) { state in
      state.currentRoute = .none
    }
    
    store.send(.derived(.decrement)) { state in
      state.derived.value -= 1
    }
  }
  
  func testExclucive() {
    struct RootState: RoutableState, Equatable {
      var currentRoute: RootRoute?
      
      var derived: DerivedState? {
        get {
          guard case let .derived(state) = currentRoute
          else { return .none }
          return state
        }
        set {
          guard
            let state = newValue,
            case .derived = currentRoute
          else { return }
          currentRoute = .derived(state)
        }
      }
    }
    
    enum RootRoute: Equatable, Taggable {
      case derived(DerivedState)
      
      var tag: Tag {
        switch self {
        case .derived:
          return .derived
        }
      }
      
      enum Tag: Hashable {
        case derived
      }
    }
    
    enum RootAction: RouterAction, Equatable {
      case derived(DerivedAction)
      case router(RoutingAction<RootRoute?>)
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
    > = derivedReducer.optional(breakpointOnNil: false).pullback(
      state: \RootState.derived,
      action: /RootAction.derived,
      environment: { _ in }
    ).routing()
    
    let store = TestStore(
      initialState: RootState(),
      reducer: rootReducer,
      environment: ()
    )
    
    let firstNavigation = DerivedState()
    store.send(.navigate(to: .derived(firstNavigation))) { state in
      state.currentRoute = .derived(firstNavigation)
    }
    
    store.send(.derived(.increment)) { state in
      state.derived?.value += 1
    }
    
    store.send(.router(.dismiss)) { state in
      state.currentRoute = nil
    }
    
    store.send(.derived(.decrement))
  }
  
  func testDismissOn() {
    struct RootState: RoutableState, Equatable {
      var currentRoute: RootRoute?
      
      var derived: DerivedState? {
        get {
          guard case let .derived(state) = currentRoute
          else { return .none }
          return state
        }
        set {
          guard
            let state = newValue,
            case .derived = currentRoute
          else { return }
          currentRoute = .derived(state)
        }
      }
    }
    
    enum RootRoute: Equatable, Taggable {
      case derived(DerivedState)
      
      var tag: Tag {
        switch self {
        case .derived:
          return .derived
        }
      }
      
      enum Tag: Hashable {
        case derived
      }
    }
    
    enum RootAction: RouterAction, Equatable {
      case derived(DerivedAction)
      case router(RoutingAction<RootRoute?>)
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
    
    let rootReducer: Reducer<
      RootState,
      RootAction,
      Void
    > = derivedReducer.optional(breakpointOnNil: false).pullback(
      state: \RootState.derived,
      action: /RootAction.derived,
      environment: { _ in }
    )
    .dismissOn(.derived(.close))
    .routing()
    
    let store = TestStore(
      initialState: RootState(),
      reducer: rootReducer,
      environment: ()
    )
    
    let firstNavigation = DerivedState()
    store.send(.navigate(to: .derived(firstNavigation))) { state in
      state.currentRoute = .derived(firstNavigation)
    }
    
    store.send(.derived(.increment)) { state in
      state.derived?.value += 1
    }
    
    store.send(.derived(.close))
    store.receive(.router(.dismiss)) { state in
      state.currentRoute = nil
    }
    
    store.send(.derived(.decrement))
  }
}
