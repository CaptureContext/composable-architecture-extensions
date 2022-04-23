#if canImport(UIKit) && !os(watchOS)
import ComposableArchitecture
import ComposableNavigation
import Combine
import CocoaAliases
import FoundationExtensions

fileprivate extension Cancellable {
  func store(in cancellable: inout Cancellable?) {
    cancellable = self
  }
}

extension ComposableViewController {
  public func configureRoutes<Route: ExpressibleByNilLiteral>(
    for publisher: StorePublisher<Route>,
    _ configurations: [RouteConfiguration<Route>],
    using action: @escaping (RoutingAction<Route>) -> Action
  ) -> Cancellable {
    self._configureRoutes(
      for: publisher,
      configurations,
      dismissCancellable: Reference(
        read: { [weak self] in
          self?.core.cancellablesStorage[#function]
        },
        write: { [weak self] cancellable in
          self?.core.cancellablesStorage[#function] = cancellable
        }
      ),
      onDismiss: { [weak self] in
        self?.core.send(action(.dismiss))
      }
    )
  }
}

extension ComposableViewController {
  public func configureRoutes<
    Route: Taggable & ExpressibleByNilLiteral
  >(
    for publisher: StorePublisher<Route.Tag>,
    _ configurations: [RouteConfiguration<Route.Tag>],
    using action: @escaping (RoutingAction<Route>) -> Action
  ) -> Cancellable where Route.Tag: ExpressibleByNilLiteral {
    self._configureRoutes(
      for: publisher,
      configurations,
      dismissCancellable: Reference(
        read: { [weak self] in
          self?.core.cancellablesStorage[#function]
        },
        write: { [weak self] cancellable in
          self?.core.cancellablesStorage[#function] = cancellable
        }
      ),
      onDismiss: { [weak self] in
        self?.core.send(action(.dismiss))
      }
    )
  }
}

extension CocoaViewController {
  fileprivate func _configureRoutes<
    P: Publisher,
    Route: ExpressibleByNilLiteral & Equatable
  >(
    for publisher: P,
    _ configurations: [RouteConfiguration<Route>],
    dismissCancellable: Reference<Cancellable?>,
    onDismiss: @escaping () -> Void
  ) -> Cancellable where P.Output == Route, P.Failure == Never {
    publisher
      .removeDuplicates()
      .receive(on: UIScheduler.shared)
      .sink { [weak self] route in
        guard let self = self else { return }
        let configuration = configurations.first(where: { $0.target == route })
        let destination = configuration.map { $0.getController }
        self.navigate(
          to: destination,
          beforePush: {
            self.configureNavigationDismiss(onDismiss)
              .store(in: &dismissCancellable.wrappedValue)
          }
        )
      }
  }
  
  private func navigate(
    to destination: (() -> CocoaViewController)?,
    beforePush: () -> Void
  ) {
    guard let navigationController = self.navigationController
    else { return }
    
    let isDismiss = destination == nil
      && navigationController.visibleViewController !== self
    
    if isDismiss {
      guard navigationController.viewControllers.contains(self) else {
        navigationController.popToRootViewController(animated: true)
        return
      }
      navigationController.popToViewController(self, animated: true)
    } else if let destination = destination {
      let controller = destination()
      
      if navigationController.viewControllers.contains(self) {
        if navigationController.viewControllers.last !== self {
          navigationController.popToViewController(self, animated: false)
        }
      }
      
      beforePush()
      navigationController.pushViewController(controller, animated: true)
    }
  }
  
  private func configureNavigationDismiss(
    _ action: @escaping () -> Void
  ) -> Cancellable {
    let localRoot = navigationController?.topViewController
    
    let first = navigationController?
      .publisher(for: #selector(UINavigationController.popViewController))
      .receive(on: UIScheduler.shared)
      .sink { [weak self, weak localRoot] in
        guard
          let self = self,
          let localRoot = localRoot,
          self.navigationController?.visibleViewController === localRoot
        else { return }
        if let coordinator = self.navigationController?.transitionCoordinator {
          coordinator.animate(alongsideTransition: nil) { context in
            if !context.isCancelled { action() }
          }
        } else {
          action()
        }
      }
    
    let second: Cancellable? = navigationController?
      .publisher(for: #selector(UINavigationController.popToViewController))
      .receive(on: UIScheduler.shared)
      .sink { [weak self] in
        guard
          let self = self,
          let navigationController = self.navigationController,
          !navigationController.viewControllers.contains(self)
        else { return }
        if let coordinator = self.navigationController?.transitionCoordinator {
          coordinator.animate(alongsideTransition: nil) { context in
            if !context.isCancelled { action() }
          }
        } else {
          action()
        }
      }
    
    let third = navigationController?
      .publisher(for: #selector(UINavigationController.popToRootViewController))
      .receive(on: UIScheduler.shared)
      .sink { action() }
    
    let cancellable = AnyCancellable {
      first?.cancel()
      second?.cancel()
      third?.cancel()
    }
    
    return cancellable
  }
}

public struct RouteConfiguration<Target: Hashable> {
  public static func associate<Controller: ComposableViewControllerProtocol>(
    _ childController: ComposableChildController<Controller>,
    with target: Target
  ) -> RouteConfiguration { .init(for: childController, target: target) }
  
  public init<Controller: ComposableViewControllerProtocol>(
    for childController: ComposableChildController<Controller>,
    target: Target
  ) {
    self.init(for: childController.initIfNeeded, target: target)
  }
  
  public static func associate(
    _ controller: @escaping () -> CocoaViewController,
    with target: Target
  ) -> RouteConfiguration { .init(for: controller, target: target) }
  
  public init(
    for controller: @escaping () -> CocoaViewController,
    target: Target
  ) {
    self.getController = controller
    self.target = target
  }
  
  var getController: () -> CocoaViewController
  var target: Target
}

#endif
