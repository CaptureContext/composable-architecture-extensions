import ComposableArchitecture

extension ReducerProtocol {
  @inlinable
  public func optional(
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> some ReducerProtocol<State?, Action> {
    EmptyReducer<State?, Action>().ifLet(
      \State.self,
       action: /.self,
       then: { self },
       file: file,
       fileID: fileID,
       line: line
    )
  }
}
