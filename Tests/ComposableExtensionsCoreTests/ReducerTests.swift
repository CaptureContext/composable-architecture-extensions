import ComposableExtensionsCore
import Testing
import FoundationExtensions

@MainActor
@Suite
struct ReducerTests {
	@Reducer
	struct Feature {
		@ObservableState
		struct State: Equatable {
			var value: Int = 0
			var savedValues: [Int] = []
		}

		@CasePathable
		enum Action: Equatable {
			case setValue(Int)
			case saveValue(Int)
		}

		func reduce(
			into state: inout State,
			action: Action
		) -> Effect<Action> {
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

	@Test
	func onChange() async throws {
		let store = TestStore(
			initialState: .init(value: 1),
			reducer: { Feature()
					.onChange(of: \.value) { state, old, new in
							.send(.saveValue(old))
					}
			}
		)

		await store.send(.setValue(10)) { state in
			state.value = 10
		}

		await store.receive(.saveValue(1)) { state in
			state.savedValues.append(1)
		}

		await store.send(.setValue(5)) { state in
			state.value = 5
		}

		await store.receive(.saveValue(10)) { state in
			state.savedValues.append(10)
		}

		await store.send(.setValue(0)) { state in
			state.value = 0
		}

		await store.receive(.saveValue(5)) { state in
			state.savedValues.append(5)
		}
	}

	@Reducer
	struct ValueSetter {
		nonisolated(unsafe) static var initCount = 0

		@ObservableState
		struct State: Equatable {
			var value: Int = 0
		}

		@CasePathable
		enum Action: Equatable {
			case setValue(Int)
		}

		init() {
			Self.initCount += 1
		}

		func reduce(
			into state: inout State,
			action: Action
		) -> Effect<Action> {
			switch action {
			case let .setValue(value):
				state.value = value
				return .none
			}
		}
	}

	@Test
	func lazyReducer() async throws {
		let store = TestStore(
			initialState: ValueSetter.State(),
			reducer: {
				LazyReducer(ValueSetter())
			}
		)

		#expect(ValueSetter.initCount == 0)

		await store.send(.setValue(10)) { state in
			state.value = 10
		}

		#expect(ValueSetter.initCount == 1)
	}
}
