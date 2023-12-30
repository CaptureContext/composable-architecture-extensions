// Based on @oliverfoggin comment in TCA tips and tricks discussion
// https://github.com/pointfreeco/swift-composable-architecture/discussions/1666#discussioncomment-7490309

import ComposableArchitecture
import FoundationExtensions

public struct Pullback<State, Action: CasePathable, ChildAction>: Reducer {
	@usableFromInline
	let toChildAction: CaseKeyPath<Action, ChildAction>

	@usableFromInline
	let reduce: (inout State, ChildAction) -> Effect<Action>

//	@inlinable
//	public init<R: Reducer<State, ChildAction>>(
//		_ toChildAction: CaseKeyPath<Action, ChildAction>,
//		@ReducerBuilder<State, ChildAction> reducer: () -> R
//	) {
//		let reducer = reducer()
//		self.init(
//			action: toChildAction,
//			reduce: { state, action in
//				reducer.reduce(into: &state, action: action).map { action in
//					toChildAction(action)
//				}
//			}
//		)
//	}

	@inlinable
	public init(
		_ toChildAction: CaseKeyPath<Action, ChildAction>,
		reduce: @escaping (inout State, ChildAction) -> Effect<Action>
	) {
		self.init(
			action: toChildAction,
			reduce: reduce
		)
	}

	@usableFromInline
	init(
		action toChildAction: CaseKeyPath<Action, ChildAction>,
		reduce: @escaping (inout State, ChildAction) -> Effect<Action>
	) {
		self.toChildAction = toChildAction
		self.reduce = reduce
	}

	@inlinable
	public func reduce(into state: inout State, action: Action) -> Effect<Action> {
		guard let childAction = action[case: toChildAction] else {
			return .none
		}

		return reduce(&state, childAction)
	}
}

// MARK: - Void

extension Pullback where ChildAction == Void {
	@inlinable
	public init(
		_ toChildAction: CaseKeyPath<Action, Void>,
		reduce: @escaping (inout State) -> Effect<Action>
	) {
		self.init(
			action: toChildAction,
			reduce: { state, action in reduce(&state) }
		)
	}
}

// MARK: - IdentifiedAction

extension Pullback {
	@inlinable
	public init<ID: Hashable, ElementAction>(
		_ toChildAction: CaseKeyPath<Action, ChildAction>,
		reduce: @escaping (inout State, ID, ElementAction) -> Effect<Action>
	) where ChildAction == IdentifiedAction<ID, ElementAction> {
		self.init(
			action: toChildAction,
			reduce: { state, action in
				switch action {
				case let .element(id, action):
					return reduce(&state, id, action)
				}
			}
		)
	}

	@inlinable
	public init<ID: Hashable, ElementAction: CasePathable, DerivedAction: CasePathable>(
		_ toIdentifiedAction: CaseKeyPath<Action, IdentifiedAction<ID, ElementAction>>,
		element toDerivedAction: CaseKeyPath<ElementAction, DerivedAction>,
		reduce: @escaping (inout State, ID, DerivedAction) -> Effect<Action>
	) where ChildAction == IdentifiedAction<ID, ElementAction> {
		self.init(
			action: toIdentifiedAction,
			reduce: { state, action in
				switch action {
				case let .element(id, action):
					guard let action = action[case: toDerivedAction]
					else { return .none }

					return reduce(&state, id, action)
				}
			}
		)
	}

	// MARK: Void

	@inlinable
	public init<ID: Hashable, ElementAction: CasePathable>(
		_ toIdentifiedAction: CaseKeyPath<Action, IdentifiedAction<ID, ElementAction>>,
		element toDerivedAction: CaseKeyPath<ElementAction, Void>,
		reduce: @escaping (inout State, ID) -> Effect<Action>
	) where ChildAction == IdentifiedAction<ID, ElementAction> {
		self.init(
			action: toIdentifiedAction,
			reduce: { state, action in
				switch action {
				case let .element(id, action):
					guard action[case: toDerivedAction].isNotNil
					else { return .none }

					return reduce(&state, id)
				}
			}
		)
	}
}
