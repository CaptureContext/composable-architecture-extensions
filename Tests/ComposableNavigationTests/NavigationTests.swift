import ComposableArchitecture
import ComposableNavigation
import XCTest
import CasePaths

final class NavigationTests: XCTestCase {
  func testStored() {
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
      struct State: RoutableState, Equatable {
        var derived: DerivedFeature.State = .init()
        var currentRoute: Route? = .none
      }
      
      enum Route: Hashable {
        case derived
      }
      
      enum Action: RoutableAction, Equatable {
        case derived(DerivedFeature.Action)
        case router(RoutingAction<Route?>)
      }
      
      var body: some ReducerProtocol<State, Action> {
        Scope(
          state: \State.derived,
          action: /Action.derived,
          DerivedFeature.init
        )
        .routing()
      }
    }
    
    let store = TestStore(
      initialState: .init(),
      reducer: RootFeature()
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
      struct State: RoutableState, Equatable {
        var currentRoute: Route?
        
        var derived: DerivedFeature.State? {
          get { (/RootFeature.Route.derived).extract(from: currentRoute) }
          set { (/RootFeature.Route.derived).ifCaseLetEmbed(newValue, in: &currentRoute) }
        }
      }
      
      enum Route: Equatable, Taggable {
        case derived(DerivedFeature.State)
        
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
      
      enum Action: RoutableAction, Equatable {
        case derived(DerivedFeature.Action)
        case router(RoutingAction<Route?>)
      }
      
      var body: some ReducerProtocol<State, Action> {
        Scope(
          state: \State.derived,
          action: /Action.derived
        ) {
          DerivedFeature().optional()
        }
        .routing()
      }
    }
    
    let store = TestStore(
      initialState: .init(),
      reducer: RootFeature()
    )
    
    let firstNavigation = DerivedFeature.State()
    store.send(.navigate(to: .derived(firstNavigation))) { state in
      state.currentRoute = .derived(firstNavigation)
    }
    
    store.send(.derived(.increment)) { state in
      state.derived?.value += 1
    }
    
    store.send(.router(.dismiss)) { state in
      state.currentRoute = nil
    }

    // Pointfree removed "disable nil warnings" feature
    // from ifLet/scope stores etc. so there is no way
    // to allow you to don't care about redundant actions 😢
    // Maybe we'll add a workaround later, or just stick
    // with the main approach... (to be discussed)

    // store.send(.derived(.decrement))
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
      struct State: RoutableState, Equatable {
        var currentRoute: Route?
        
        var derived: DerivedFeature.State? {
          get { (/RootFeature.Route.derived).extract(from: currentRoute) }
          set { (/RootFeature.Route.derived).ifCaseLetEmbed(newValue, in: &currentRoute) }
        }
      }
      
      enum Route: Equatable, Taggable {
        case derived(DerivedFeature.State)
        
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
      
      enum Action: RoutableAction, Equatable {
        case derived(DerivedFeature.Action)
        case router(RoutingAction<Route?>)
      }
      
      var body: some ReducerProtocol<State, Action> {
        Scope(
          state: \State.derived,
          action: /Action.derived
        ) {
          DerivedFeature().optional()
        }
        .dismissOn(.derived(.close))
        .routing()
      }
    }
    
    let store = TestStore(
      initialState: .init(),
      reducer: RootFeature()
    )
    
    let firstNavigation = DerivedFeature.State()
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

    // Pointfree removed "disable nil warnings" feature
    // from ifLet/scope stores etc. so there is no way
    // to allow you to don't care about redundant actions 😢
    // Maybe we'll add a workaround later, or just stick
    // with the main approach... (to be discussed)

    // store.send(.derived(.decrement))
  }
}
