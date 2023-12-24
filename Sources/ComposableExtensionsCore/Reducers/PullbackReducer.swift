// Based on @oliverfoggin comment in TCA tips and tricks discussion
// https://github.com/pointfreeco/swift-composable-architecture/discussions/1666#discussioncomment-7490309

import ComposableArchitecture

public struct Pullback<State, Action: CasePathable, ChildAction>: Reducer {
	@usableFromInline
	let toChildAction: CaseKeyPath<Action, ChildAction>

	@usableFromInline
	let toEffect: (inout State, ChildAction) -> Effect<Action>

	@inlinable
	public init(
		_ action: CaseKeyPath<Action, ChildAction>,
		toEffect: @escaping (inout State, ChildAction) -> Effect<Action>
	) {
		self.init(toChildAction: action, toEffect: toEffect)
	}

	@usableFromInline
	init(
		toChildAction: CaseKeyPath<Action, ChildAction>,
		toEffect: @escaping (inout State, ChildAction) -> Effect<Action>
	) {
		self.toChildAction = toChildAction
		self.toEffect = toEffect
	}

	public func reduce(into state: inout State, action: Action) -> Effect<Action> {
		guard let childAction = action[case: toChildAction] else {
			return .none
		}

		return toEffect(&state, childAction)
	}
}

extension Pullback where ChildAction == Void {
	@inlinable
	public init(
		_ action: CaseKeyPath<Action, Void>,
		toEffect: @escaping (inout State) -> Effect<Action>
	) {
		self.init(toChildAction: action, toEffect: { state, action in toEffect(&state) })
	}
}
