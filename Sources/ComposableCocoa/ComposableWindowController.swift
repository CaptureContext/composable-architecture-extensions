#if canImport(AppKit)
import CocoaExtensions

open class ComposableWindowController<
  State: Equatable,
  Action
>:
  CustomCocoaWindowController,
  ComposableObjectProtocol
{
  public let core: ComposableCore<State, Action> = .init()
  
  open override func _init() {
    super._init()
    __setupCore()
  }

  @inlinable
  open func scope(_ store: Store<State, Action>?) {}

  @inlinable
  open func storeWillSet(
    from oldStore: Store<State, Action>?,
    to newStore: Store<State, Action>?
  ) {}

  @inlinable
  open func storeWasSet(
    from oldStore: Store<State, Action>?,
    to newStore: Store<State, Action>?
  ) {}

  @inlinable
  open func bind(
    _ state: StorePublisher<State>,
    into cancellables: inout Core.Cancellables
  ) {}
}
#endif
