#if !os(watchOS)
import Combine
import ComposableArchitecture
import DeclarativeConfiguration

@propertyWrapper
final public class ComposableChildController<Controller: ComposableViewControllerProtocol>
where Controller.State: Equatable {
  private(set) public var store: Controller.Core.Store?
  private(set) public weak var controller: Controller?
  private(set) public var configurator: Configurator<Controller>?

  private var localSubscriptions: Set<AnyCancellable> = []

  public init() {}

  public var wrappedValue: Controller? { controller }
  public var projectedValue: ComposableChildController<Controller> { self }

  public func setConfiguration(
    _ config: ((Configurator<Controller>) -> Configurator<Controller>)?
  ) {
    configurator = config.map(Configurator.init)
    controller.map { configurator?.configure($0) }
  }

  /// Sets a new store to the intance and it's controller
  ///
  /// Note: Store is capured strongly, so if controller is `nil`, store will be set to controller as soon as the controller is set.
  public func setStore(
    _ store: Store<
      Controller.Core.State?,
      Controller.Core.Action
    >?
  ) {
    if let store = store {
      localSubscriptions = []
      store
        .ifLet(
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
  public func setStore(_ store: Controller.Core.Store?) {
    self.store = store
    self.controller?.core.setStore(store)
  }

  public func releaseStore() { setStore(Store?.none) }

  public func setController(
    _ controller: Controller,
    then performAction: (Controller) -> Void
  ) { setController(controller).map(performAction) }

  @discardableResult
  public func setController(
    _ controller: Controller?
  ) -> Controller? {
    self.controller = controller
    controller.map { self.configurator?.configure($0) }
    store.map { controller?.core.setStore($0) }
    return controller
  }

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
