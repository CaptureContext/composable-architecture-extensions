import ComposableArchitecture

extension Reducer {
	@inlinable
	public func optional(
		file: StaticString = #file,
		fileID: StaticString = #fileID,
		line: UInt = #line
	) -> some Reducer<State?, Action> {
		EmptyReducer<State?, Action>().ifLet(
			\State?.self,
			action: \.self,
			then: { self },
			fileID: fileID,
			line: line
		)
	}
}
