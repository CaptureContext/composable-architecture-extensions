#if !os(watchOS)
import CocoaExtensions
import ComposableCore
import CocoaAliases

public protocol ComposableCocoaViewProtocol:
  CocoaView,
  ComposableObjectProtocol
{}

open class ComposableCocoaView<
  State,
  Action
>: CustomCocoaView, ComposableCocoaViewProtocol {
  public let core: ComposableCore<State, Action> = .init()
  
  open override func _init() {
    super._init()
    self.__setupCore()
  }
  
  open func scope(
    _ store: Core.Store?
  ) {}
  
  open func storeWillSet(
    from oldStore: Core.Store?,
    to newStore: Core.Store?
  ) {}
  
  open func storeWasSet(
    from oldStore: Core.Store?,
    to newStore: Core.Store?
  ) {}
  
  open func bind(
    _ state: Core.StorePublisher,
    into cancellables: inout Core.Cancellables
  ) {}
}
#endif
