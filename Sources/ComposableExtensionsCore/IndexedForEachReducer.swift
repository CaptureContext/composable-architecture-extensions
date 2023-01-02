import ComposableArchitecture

extension ReducerProtocol {
  @inlinable
  public func forEach<Element: ReducerProtocol>(
    _ toElementsState: WritableKeyPath<State, [Element.State]>,
    action toElementAction: CasePath<Action, (Int, Element.Action)>,
    @ReducerBuilderOf<Element> _ element: () -> Element,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> some ReducerProtocol<State, Action> {
    _IndexedForEachReducer(
      parent: self,
      toElementsState: toElementsState,
      toElementAction: toElementAction,
      element: element(),
      file: file,
      fileID: fileID,
      line: line
    )
  }
}

@usableFromInline
struct _IndexedForEachReducer<
  Parent: ReducerProtocol, Element: ReducerProtocol
>: ReducerProtocol {
  @usableFromInline
  let parent: Parent

  @usableFromInline
  let toElementsState: WritableKeyPath<Parent.State, [Element.State]>

  @usableFromInline
  let toElementAction: CasePath<Parent.Action, (Int, Element.Action)>

  @usableFromInline
  let element: Element

  @usableFromInline
  let file: StaticString

  @usableFromInline
  let fileID: StaticString

  @usableFromInline
  let line: UInt

  @usableFromInline
  init(
    parent: Parent,
    toElementsState: WritableKeyPath<Parent.State, [Element.State]>,
    toElementAction: CasePath<Parent.Action, (Int, Element.Action)>,
    element: Element,
    file: StaticString,
    fileID: StaticString,
    line: UInt
  ) {
    self.parent = parent
    self.toElementsState = toElementsState
    self.toElementAction = toElementAction
    self.element = element
    self.file = file
    self.fileID = fileID
    self.line = line
  }

  @inlinable
  public func reduce(
    into state: inout Parent.State, action: Parent.Action
  ) -> EffectTask<Parent.Action> {
    self.reduceForEach(into: &state, action: action)
      .merge(with: self.parent.reduce(into: &state, action: action))
  }

  @inlinable
  func reduceForEach(
    into state: inout Parent.State, action: Parent.Action
  ) -> EffectTask<Parent.Action> {
    guard let (index, elementAction) = self.toElementAction.extract(from: action)
    else { return .none }

    guard state[keyPath: self.toElementsState].indices.contains(index) else {
      runtimeWarn(
        """
        A "forEach" at "\(self.fileID):\(self.line)" received an action for a missing element.

          Action:
            \(debugCaseOutput(action))

        This is generally considered an application logic error, and can happen for a few reasons:

        • A parent reducer removed an element at this index before this reducer ran. This reducer \
        must run before any other reducer removes an element, which ensures that element reducers \
        can handle their actions while their state is still available.

        • An in-flight effect emitted this action when state contained no element at this index. \
        While it may be perfectly reasonable to ignore this action, consider canceling the \
        associated effect before an element is removed, especially if it is a long-living effect.

        • This action was sent to the store while its state contained no element at this index. To \
        fix this make sure that actions for this reducer can only be sent from a view store when \
        its state contains an element at this index. In SwiftUI applications, use "ForEachStore" and IdentifiedArray.
        """,
        file: self.file,
        line: self.line
      )
      return .none
    }

    return self.element
      .reduce(into: &state[keyPath: self.toElementsState][index], action: elementAction)
      .map { self.toElementAction.embed((index, $0)) }
  }
}
