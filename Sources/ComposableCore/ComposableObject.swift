import ComposableArchitecture
import Combine
import Foundation

open class ComposableObject<State: Equatable, Action>:
  NSObject,
  ComposableObjectProtocol
{
  public let core: ComposableCore<State, Action> = .init()

  public override init() {
    super.init()
    self.__setupCore()
  }

  @inlinable
  open func scope(
    _ store: Core.Store?
  ) {}

  @inlinable
  open func storeWillSet(
    from oldStore: Core.Store?,
    to newStore: Core.Store?
  ) {}

  @inlinable
  open func storeWasSet(
    from oldStore: Core.Store?,
    to newStore: Core.Store?
  ) {}

  @inlinable
  open func bind(
    _ state: Core.StorePublisher,
    into cancellables: inout Core.Cancellables
  ) {}
}
