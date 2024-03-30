import XCTest
@testable import ComposableCore

final class ComposableCoreTests: XCTestCase {
	@Reducer
	struct DerivedFeature {
		@ObservableState
		struct State: Equatable {
			var value: Int = 0
		}

		@CasePathable
		enum Action: Equatable {
			case inc, dec
		}

		func reduce(
			into state: inout State,
			action: Action
		) -> Effect<Action> {
			switch action {
			case .inc:
				state.value += 1
				return .none

			case .dec:
				state.value -= 1
				return .none
			}
		}
	}

	@Reducer
	struct ParentFeature {
		@ObservableState
		struct State: Equatable {
			var derived: DerivedFeature.State = .init()
		}

		@CasePathable
		enum Action: Equatable {
			case derived(DerivedFeature.Action)
		}

		var body: some Reducer<State, Action> {
			Scope(
				state: \.derived,
				action: \.derived,
				child: DerivedFeature.init
			)
		}
	}

	class DerivedFeatureObject: ComposableObject<
		DerivedFeature.State,
		DerivedFeature.Action
	> {
		var value: Int?

		func increment() { store?.send(.inc) }

		func decrement() { store?.send(.dec) }

		override func bind(
			_ state: StorePublisher,
			into cancellables: inout Cancellables
		) {
			state.value
				.sink(receiveValue: { [weak self] value in
					self?.value = value
				})
				.store(in: &cancellables)
		}
	}

	class ParentFeatureObject: ComposableObject<
	ParentFeature.State,
	ParentFeature.Action
	> {
		var derived: DerivedFeatureObject = .init()
		var value: Int?

		override func scope(_ store: Store?) {
			derived.setStore(store?.scope(
				state: \.derived,
				action: \.derived
			))
		}

		override func bind(
			_ state: StorePublisher,
			into cancellables: inout Cancellables
		) {
			state.derived.value
				.sink(receiveValue: { [weak self] value in
					self?.value = value
				})
				.store(in: &cancellables)
		}
	}

	func testScoping() {
		let parent = ParentFeatureObject()
		let derived = parent.derived

		do {
			XCTAssertEqual(parent.store?.derived, derived.store?.state)
			XCTAssertEqual(derived.store?.value, nil)
			XCTAssertEqual(parent.value, derived.value)
			XCTAssertEqual(derived.value, nil)
		}

		do {
			parent.setStore(Store(
				initialState: ParentFeature.State(),
				reducer: ParentFeature.init
			))

			XCTAssertEqual(parent.store?.derived, derived.store?.state)
			XCTAssertEqual(derived.store?.value, 0)
			XCTAssertEqual(parent.value, derived.value)
			XCTAssertEqual(derived.value, 0)
		}

		do {
			derived.increment()

			XCTAssertEqual(parent.store?.derived, derived.store?.state)
			XCTAssertEqual(derived.store?.value, 1)
			XCTAssertEqual(parent.value, derived.value)
			XCTAssertEqual(derived.value, 1)
		}

		do {
			derived.store?.send(.inc)

			XCTAssertEqual(parent.store?.derived, derived.store?.state)
			XCTAssertEqual(derived.store?.value, 2)
			XCTAssertEqual(parent.value, derived.value)
			XCTAssertEqual(derived.value, 2)
		}

		do {
			parent.store?.send(.derived(.inc))

			XCTAssertEqual(parent.store?.derived, derived.store?.state)
			XCTAssertEqual(derived.store?.value, 3)
			XCTAssertEqual(parent.value, derived.value)
			XCTAssertEqual(derived.value, 3)
		}

		do {
			parent.derived.store?.send(.dec)
			derived.store?.send(.dec)
			derived.decrement()

			XCTAssertEqual(parent.store?.derived, derived.store?.state)
			XCTAssertEqual(derived.store?.value, 0)
			XCTAssertEqual(parent.value, derived.value)
			XCTAssertEqual(derived.value, 0)
		}
	}
}
