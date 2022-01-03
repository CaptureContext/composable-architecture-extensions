import XCTest
@testable import ComposableCore

final class ComposableCoreTests: XCTestCase {
  func testScoping() {
    struct ParentState: Equatable {
      var derived: DerivedState = .init()
    }
    
    struct DerivedState: Equatable {
      var value: Int = 0
    }
    
    enum ParentAction: Equatable {
      case derived(DerivedAction)
    }
    
    enum DerivedAction: Equatable {
      case inc, dec
    }
    
    let derivedReducer = Reducer<
      DerivedState,
      DerivedAction,
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
    
    class DerivedObject: ComposableObject<DerivedState, DerivedAction> {
      var value: Int?
      
      func increment() { core.send(.inc) }
      
      func decrement() { core.send(.dec) }
      
      override func bind(
        _ state: Core.StorePublisher,
        into cancellables: inout Core.Cancellables
      ) {
        state.value
          .sinkValues({ [weak self] value in
            self?.value = value
          })
          .store(in: &cancellables)
      }
    }
    
    class ParentObject: ComposableObject<ParentState, ParentAction> {
      var derived: DerivedObject = .init()
      var value: Int?
      
      override func scope(_ store: Store<ParentState, ParentAction>?) {
        derived.core.setStore(
          store?._scope(
            state: \State.derived,
            action: Action.derived
          )
        )
      }
      
      override func bind(
        _ state: Core.StorePublisher,
        into cancellables: inout Core.Cancellables
      ) {
        state.derived.value
          .sinkValues({ [weak self] value in
            self?.value = value
          })
          .store(in: &cancellables)
      }
    }
    
    let parent = ParentObject()
    let derived = parent.derived
    
    XCTAssertEqual(parent.core.state?.derived, derived.core.state)
    XCTAssertEqual(derived.core.state?.value, nil)
    XCTAssertEqual(parent.value, derived.value)
    XCTAssertEqual(derived.value, nil)
    
    parent.core.setStore(
      Store<ParentState, ParentAction>(
        initialState: ParentState(),
        reducer: derivedReducer.pullback(
          state: \ParentState.derived,
          action: /ParentAction.derived,
          environment: { }
        ),
        environment: ()
      )
    )
    
    XCTAssertEqual(parent.core.state?.derived, derived.core.state)
    XCTAssertEqual(derived.core.state?.value, 0)
    XCTAssertEqual(parent.value, derived.value)
    XCTAssertEqual(derived.value, 0)
    
    derived.increment()
    
    XCTAssertEqual(parent.core.state?.derived, derived.core.state)
    XCTAssertEqual(derived.core.state?.value, 1)
    XCTAssertEqual(parent.value, derived.value)
    XCTAssertEqual(derived.value, 1)
    
    derived.core.send(.inc)
    
    XCTAssertEqual(parent.core.state?.derived, derived.core.state)
    XCTAssertEqual(derived.core.state?.value, 2)
    XCTAssertEqual(parent.value, derived.value)
    XCTAssertEqual(derived.value, 2)
    
    parent.core.send(.derived(.inc))
    
    XCTAssertEqual(parent.core.state?.derived, derived.core.state)
    XCTAssertEqual(derived.core.state?.value, 3)
    XCTAssertEqual(parent.value, derived.value)
    XCTAssertEqual(derived.value, 3)
    
    parent.derived.core.send(.dec)
    derived.core.send(.dec)
    derived.decrement()
    
    XCTAssertEqual(parent.core.state?.derived, derived.core.state)
    XCTAssertEqual(derived.core.state?.value, 0)
    XCTAssertEqual(parent.value, derived.value)
    XCTAssertEqual(derived.value, 0)
  }
}
