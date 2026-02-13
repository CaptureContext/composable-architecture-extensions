import ComposableArchitecture

extension Reducer {
	@inlinable
	@warn_unqualified_access
	public func forEach<
		ElementState,
		ElementAction,
		ID: Hashable,
		Element: Reducer<ElementState, ElementAction>
	>(
		state toElementsState: WritableKeyPath<State, IdentifiedArray<ID, ElementState>>,
		action toElementAction: CaseKeyPath<Action, IdentifiedAction<ID, ElementAction>>,
		@ReducerBuilder<ElementState, ElementAction> element: () -> Element,
		fileID: StaticString = #fileID,
		filePath: StaticString = #filePath,
		line: UInt = #line,
		column: UInt = #column
	) -> some Reducer<State, Action> {
		self.forEach(
			toElementsState,
			action: toElementAction,
			element: element,
			fileID: fileID,
			filePath: filePath,
			line: line,
			column: column
		)
	}
}
