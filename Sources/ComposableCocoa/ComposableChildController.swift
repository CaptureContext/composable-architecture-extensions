#if !os(watchOS)
import Combine
import ComposableArchitecture
import DeclarativeConfiguration

@propertyWrapper
final public class ComposableChildController<Controller: ComposableViewControllerProtocol>
where Controller.State: Equatable {
  @usableFromInline
  var _store: Controller.Core.Store?

  @usableFromInline
  weak var _controller: Controller?

  @usableFromInline
  var _configurator: Configurator<Controller>?

  @inlinable
  public var store: Controller.Core.Store? { _store }

  @inlinable
  public weak var controller: Controller? { _controller }

  @inlinable
  public var configurator: Configurator<Controller>? { _configurator }

  @usableFromInline
  var localSubscriptions: Set<AnyCancellable> = []

  @inlinable
  public init() {}

  @inlinable
  public var wrappedValue: Controller? { _controller }

  @inlinable
  public var projectedValue: ComposableChildController<Controller> { self }

  @inlinable
  public func setConfiguration(
    _ config: ((Configurator<Controller>) -> Configurator<Controller>)?
  ) {
    _configurator = config.map(Configurator.init)
    _controller.map { configurator?.configure($0) }
  }

  /// Sets a new store to the intance and it's controller
  ///
  /// Note: Store is capured strongly, so if controller is `nil`, store will be set to controller as soon as the controller is set.
  @inlinable
  public func setStore(
    _ store: Store<
      Controller.Core.State?,
      Controller.Core.Action
    >?
  ) {
    if let store = store {
      localSubscriptions = []
      store
        ._ifLet(
          then: { [weak self] store in
            self?.setStore(store)
          },
          else: { [weak self] in
            self?.releaseStore()
          }
        )
        .store(in: &localSubscriptions)
    } else {
      releaseStore()
    }
  }

  /// Sets a new store to the intance and it's controller
  ///
  /// Note: Store is capured strongly, so if controller is `nil`, store will be set to controller as soon as the controller is set.
  @inlinable
  public func setStore(_ store: Controller.Core.Store?) {
    self._store = store
    self._controller?.core.setStore(store)
  }

  @inlinable
  public func releaseStore() { setStore(Store?.none) }

  @inlinable
  public func setController(
    _ controller: Controller,
    then performAction: (Controller) -> Void
  ) { setController(controller).map(performAction) }

  @discardableResult
  @inlinable
  public func setController(
    _ controller: Controller?
  ) -> Controller? {
    self._controller = controller
    controller.map { self.configurator?.configure($0) }
    store.map { controller?.core.setStore($0) }
    return controller
  }

  @inlinable
  public func initIfNeeded() -> Controller {
    if let controller = controller {
      return controller
    } else {
      let controller = Controller()
      self.setController(controller)
      return controller
    }
  }
}
#endif
