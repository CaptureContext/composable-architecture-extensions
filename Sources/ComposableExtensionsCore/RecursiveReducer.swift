import ComposableArchitecture

extension ReducerProtocol {
  @inlinable
  public func recursive<Parent: ReducerProtocol>(
    reducer: Parent,
    state toNestedState: WritableKeyPath<State, [State]>,
    action toNestedAction: CasePath<Action, (Int, Action)>,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> some ReducerProtocol<State, Action>
  where State == Parent.State, Action == Parent.Action {
    return self.forEach(
      toNestedState,
      action: toNestedAction,
      { reducer },
      file: file,
      fileID: fileID,
      line: line
    )
  }

  @inlinable
  public func recursive<Parent: ReducerProtocol, ID: Hashable>(
    reducer: Parent,
    state toNestedState: WritableKeyPath<State, IdentifiedArray<ID, State>>,
    action toNestedAction: CasePath<Action, (ID, Action)>,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> some ReducerProtocol<State, Action>
  where State == Parent.State, Action == Parent.Action {
    return self.forEach(
      toNestedState,
      action: toNestedAction,
      { reducer },
      file: file,
      fileID: fileID,
      line: line
    )
  }
}
