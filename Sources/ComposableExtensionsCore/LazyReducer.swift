import ComposableArchitecture
import FoundationExtensions

public struct LazyReducer<Wrapped: ReducerProtocol>: ReducerProtocol {
  public typealias State = Wrapped.State
  public typealias Action = Wrapped.Action

  @usableFromInline
  let makeReducer: () -> Wrapped

  @usableFromInline
  var reducer: Indirect<Wrapped?> = .init(nil)

  @inlinable
  public init(
    @ReducerBuilderOf<Wrapped> _ build: @escaping () -> Wrapped
  ) {
    self.makeReducer = build
  }

  @inlinable
  public init(
    _ reducer: @escaping @autoclosure () -> Wrapped
  ) {
    self.makeReducer = reducer
  }

  @inlinable
  public func reduce(
    into state: inout Wrapped.State, action: Wrapped.Action
  ) -> EffectTask<Wrapped.Action> {
    switch reducer.wrappedValue {
    case let .some(wrapped):
      return wrapped.reduce(into: &state, action: action)
    case .none:
      reducer._setValue(makeReducer())
      return reduce(into: &state, action: action)
    }
  }
}
