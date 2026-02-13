// Based on @oliverfoggin comment in TCA tips and tricks discussion
// https://github.com/pointfreeco/swift-composable-architecture/discussions/1666#discussioncomment-7490309

import ComposableArchitecture
import FoundationExtensions

public struct Pullback<State, Action: CasePathable, ChildAction>: Reducer {
	@usableFromInline
	let toChildAction: CaseKeyPath<Action, ChildAction>

	@usableFromInline
	let reduce: (inout State, ChildAction) -> Effect<Action>

	@_disfavoredOverload
	@inlinable
	public init<R: Reducer<State, ChildAction>>(
		_ toChildAction: CaseKeyPath<Action, ChildAction> & Sendable,
		@ReducerBuilder<State, ChildAction> reducer: () -> R
	) where Action: Sendable {
		let reducer = reducer()
		self.init(
			action: toChildAction,
			reduce: { state, action in
				reducer.reduce(into: &state, action: action).map { action in
					toChildAction(action)
				}
			}
		)
	}

	/// Intializer that won't confilct with other inits
	///
	/// This init hepls detecting ambiguouty reason.
	/// > Usually the reason is returning an action instead of `Effect<Action>`
	@available(*, deprecated, renamed: "init(_:reduce:)", message: "For debugging only")
	@inlinable
	public static func __detect_ambiguouty_reason_2args(
		_ toChildAction: CaseKeyPath<Action, ChildAction>,
		reduce: @escaping (inout State, ChildAction) -> Effect<Action>
	) -> Self {
		Pullback(
			toChildAction,
			reduce: reduce
		)
	}

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

extension Pullback {
	/// Intializer that won't confilct with other inits
	///
	/// This init hepls detecting ambiguouty reason.
	/// > Usually the reason is returning an action instead of `Effect<Action>`
	@available(*, deprecated, renamed: "init(_:reduce:)", message: "For debugging only")
	@inlinable
	public static func __detect_ambiguouty_reason_1arg(
		_ toChildAction: CaseKeyPath<Action, ChildAction>,
		reduce: @escaping (inout State) -> Effect<Action>
	) -> Self {
		Pullback(
			toChildAction,
			reduce: reduce
		)
	}

	@inlinable
	public init(
		_ toChildAction: CaseKeyPath<Action, ChildAction>,
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
	public init<ID: Hashable, ElementAction: CasePathable, DerivedAction>(
		_ toIdentifiedAction: CaseKeyPath<Action, IdentifiedAction<ID, ElementAction>>,
		action toDerivedAction: CaseKeyPath<ElementAction, DerivedAction>,
		reduce: @escaping (inout State, ID, DerivedAction) -> Effect<Action>
	) where ChildAction == IdentifiedAction<ID, ElementAction> {
		self.init(
			toIdentifiedAction,
			reduce: { state, id, action in
				guard let action = action[case: toDerivedAction]
				else { return .none }

				return reduce(&state, id, action)
			}
		)
	}

	// MARK: Void

	@inlinable
	public init<ID: Hashable, ElementAction: CasePathable>(
		_ toIdentifiedAction: CaseKeyPath<Action, IdentifiedAction<ID, ElementAction>>,
		action toDerivedAction: CaseKeyPath<ElementAction, Void>,
		reduce: @escaping (inout State, ID) -> Effect<Action>
	) where ChildAction == IdentifiedAction<ID, ElementAction> {
		self.init(
			toIdentifiedAction,
			action: toDerivedAction,
			reduce: { state, id, _ in
				return reduce(&state, id)
			}
		)
	}
}
