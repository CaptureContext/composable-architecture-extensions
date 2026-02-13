import Testing
@testable import ComposableCore

@MainActor
@Suite
struct ComposableCoreTests {
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

		func increment() { core.store?.send(.inc) }

		func decrement() { core.store?.send(.dec) }

		override func bind(
			_ store: Store,
			into cancellables: Core.Cancellables
		) {
			observe { [weak self] in
				self?.value = store.value
			}.store(in: cancellables)
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
			_ store: Store,
			into cancellables: Core.Cancellables
		) {
			observe { [weak self] in
				self?.value = store.derived.value
			}.store(in: cancellables)
		}
	}

	func testScoping() {
		let parent = ParentFeatureObject()
		let derived = parent.derived

		do {
			#expect(parent.core.store?.derived == derived.core.store?.state)
			#expect(derived.core.store?.value == nil)
			#expect(parent.value == derived.value)
			#expect(derived.value == nil)
		}

		do {
			parent.setStore(Store(
				initialState: ParentFeature.State(),
				reducer: ParentFeature.init
			))

			#expect(parent.core.store?.derived == derived.core.store?.state)
			#expect(derived.core.store?.value == 0)
			#expect(parent.value == derived.value)
			#expect(derived.value == 0)
		}

		do {
			derived.increment()

			#expect(parent.core.store?.derived == derived.core.store?.state)
			#expect(derived.core.store?.value == 1)
			#expect(parent.value == derived.value)
			#expect(derived.value == 1)
		}

		do {
			derived.core.store?.send(.inc)

			#expect(parent.core.store?.derived == derived.core.store?.state)
			#expect(derived.core.store?.value == 2)
			#expect(parent.value == derived.value)
			#expect(derived.value == 2)
		}

		do {
			parent.core.store?.send(.derived(.inc))

			#expect(parent.core.store?.derived == derived.core.store?.state)
			#expect(derived.core.store?.value == 3)
			#expect(parent.value == derived.value)
			#expect(derived.value == 3)
		}

		do {
			parent.derived.core.store?.send(.dec)
			derived.core.store?.send(.dec)
			derived.decrement()

			#expect(parent.core.store?.derived == derived.core.store?.state)
			#expect(derived.core.store?.value == 0)
			#expect(parent.value == derived.value)
			#expect(derived.value == 0)
		}
	}
}
