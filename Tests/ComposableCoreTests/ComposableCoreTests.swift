//import XCTest
//@testable import ComposableCore
//
//final class ComposableCoreTests: XCTestCase {
//  struct DerivedFeature: Reducer {
//    struct State: Equatable {
//      var value: Int = 0
//    }
//
//    enum Action: Equatable {
//      case inc, dec
//    }
//
//    func reduce(
//      into state: inout State,
//      action: Action
//    ) -> Effect<Action> {
//      switch action {
//      case .inc:
//        state.value += 1
//        return .none
//
//      case .dec:
//        state.value -= 1
//        return .none
//      }
//    }
//  }
//
//  struct ParentFeature: Reducer {
//    struct State: Equatable {
//      var derived: DerivedFeature.State = .init()
//    }
//
//    enum Action: Equatable {
//      case derived(DerivedFeature.Action)
//    }
//
//    var body: some Reducer<State, Action> {
//      Scope(
//        state: \State.derived,
//        action: /Action.derived,
//        DerivedFeature.init
//      )
//    }
//  }
//
//  class DerivedFeatureObject: ComposableObject<
//    DerivedFeature.State,
//    DerivedFeature.Action
//  > {
//    var value: Int?
//
//    func increment() { core.send(.inc) }
//
//    func decrement() { core.send(.dec) }
//
//    override func bind(
//      _ state: Core.StorePublisher,
//      into cancellables: inout Core.Cancellables
//    ) {
//      state.value
//        .sinkValues({ [weak self] value in
//          self?.value = value
//        })
//        .store(in: &cancellables)
//    }
//  }
//
//  class ParentFeatureObject: ComposableObject<
//    ParentFeature.State,
//    ParentFeature.Action
//  > {
//    var derived: DerivedFeatureObject = .init()
//    var value: Int?
//
//    override func scope(_ store: Store<Core.State, Core.Action>?) {
//      derived.core.setStore(
//        store?._scope(
//          state: \State.derived,
//          action: Action.derived
//        )
//      )
//    }
//
//    override func bind(
//      _ state: Core.StorePublisher,
//      into cancellables: inout Core.Cancellables
//    ) {
//      state.derived.value
//        .sinkValues({ [weak self] value in
//          self?.value = value
//        })
//        .store(in: &cancellables)
//    }
//  }
//
//  func testScoping() {
//    let parent = ParentFeatureObject()
//    let derived = parent.derived
//    
//    do {
//      XCTAssertEqual(parent.core.state?.derived, derived.core.state)
//      XCTAssertEqual(derived.core.state?.value, nil)
//      XCTAssertEqual(parent.value, derived.value)
//      XCTAssertEqual(derived.value, nil)
//    }
//
//    do {
//      parent.core.setStore(
//        .init(
//          initialState: ParentFeature.State(),
//          reducer: ParentFeature()
//        )
//      )
//
//      XCTAssertEqual(parent.core.state?.derived, derived.core.state)
//      XCTAssertEqual(derived.core.state?.value, 0)
//      XCTAssertEqual(parent.value, derived.value)
//      XCTAssertEqual(derived.value, 0)
//    }
//
//    do {
//      derived.increment()
//
//      XCTAssertEqual(parent.core.state?.derived, derived.core.state)
//      XCTAssertEqual(derived.core.state?.value, 1)
//      XCTAssertEqual(parent.value, derived.value)
//      XCTAssertEqual(derived.value, 1)
//    }
//
//    do {
//      derived.core.send(.inc)
//
//      XCTAssertEqual(parent.core.state?.derived, derived.core.state)
//      XCTAssertEqual(derived.core.state?.value, 2)
//      XCTAssertEqual(parent.value, derived.value)
//      XCTAssertEqual(derived.value, 2)
//    }
//
//    do {
//      parent.core.send(.derived(.inc))
//
//      XCTAssertEqual(parent.core.state?.derived, derived.core.state)
//      XCTAssertEqual(derived.core.state?.value, 3)
//      XCTAssertEqual(parent.value, derived.value)
//      XCTAssertEqual(derived.value, 3)
//    }
//
//    do {
//      parent.derived.core.send(.dec)
//      derived.core.send(.dec)
//      derived.decrement()
//
//      XCTAssertEqual(parent.core.state?.derived, derived.core.state)
//      XCTAssertEqual(derived.core.state?.value, 0)
//      XCTAssertEqual(parent.value, derived.value)
//      XCTAssertEqual(derived.value, 0)
//    }
//  }
//}
