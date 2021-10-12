import XCTest
import ComposableArchitecture
@testable import ComposableNavigation

final class ComposableNavigationTests: XCTestCase {
  struct ParentState: RoutableState, Equatable {
    var first: Modal<FirstState?> = .init()
    var second: Modal<SecondState> = .init(state: .init())
    var third: String = "Custom route"
    var currentRoute: ParentRoute?
  }
  
  enum ParentRoute: Equatable {
    case third
  }
  
  enum ParentAction {
    case first(ModalAction<FirstAction>)
    case second(ModalAction<SecondAction>)
    case router(RoutingAction<ParentRoute>)
  }
  
  struct FirstState: Equatable {
    var value: Int = 0
  }
  
  enum FirstAction: Equatable {
    case inc, dec
  }
  
  struct SecondState: Equatable {
    var value: Bool = false
  }
  
  enum SecondAction: Equatable {
    case toggle
  }
  
  static let firstReducer = Reducer<
    FirstState,
    FirstAction,
    Void
  > { state, action, _ in
    switch action {
    case .inc:
      state.value += 1
      return .none
      
    case .dec:
      state.value -= 1
      return .none
    }
  }
  
  static let secondReducer = Reducer<
    SecondState,
    SecondAction,
    Void
  > { state, action, _ in
    switch action {
    case .toggle:
      state.value.toggle()
      return .none
    }
  }
  
  static let parentReducer = Reducer.combine(
    firstReducer
      .optional()
      .modal()
      .pullback(
        state: \ParentState.first,
        action: /ParentAction.first,
        environment: { }
      )
  )
  
}
