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

extension ComposableViewController
where
  State: RoutableState,
  State.Route: ExpressibleByNilLiteral
{
  private func navigate<Target: Equatable>(
    to target: Target?,
    using configuration: RouteConfiguration<Target>,
    action: @escaping (RoutingAction<State.Route>) -> Action
  ) {
    guard let navigationController = self.navigationController else { return }
    let destination = configuration.target
    if target.isNil, navigationController.visibleViewController !== self {
      guard navigationController.viewControllers.contains(self) else {
        navigationController.popToRootViewController(animated: true)
        return
      }
      navigationController.popToViewController(self, animated: true)
    } else if target == destination {
      let controller = configuration.getController()
      controller.setAssociatedObject(true, forKey: "composable_controller.is_configured_route")
      
      if navigationController.viewControllers.contains(self) {
        if navigationController.viewControllers.last !== self {
          navigationController.popToViewController(self, animated: false)
        }
      }
      
      configureDismiss(action: action)
      navigationController.pushViewController(controller, animated: true)
    }
  }
  
  @discardableResult
  public func configureDismiss(
    action: @escaping (RoutingAction<State.Route>) -> Action
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
            if !context.isCancelled {
              self.core.send(action(.dismiss))
            }
          }
        } else {
          self.core.send(action(.dismiss))
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
            if !context.isCancelled {
              self.core.send(action(.dismiss))
            }
          }
        } else {
          self.core.send(action(.dismiss))
        }
      }
    
    let third = navigationController?
      .publisher(for: #selector(UINavigationController.popToRootViewController))
      .receive(on: UIScheduler.shared)
      .sink { [weak self] in
        self?.core.send(action(.dismiss))
      }
    
    let cancellable = AnyCancellable {
      first?.cancel()
      second?.cancel()
      third?.cancel()
    }
    
    cancellable.store(
      in: &self.core.cancellablesStorage[#function]
    )
    
    return cancellable
  }
}

extension ComposableViewController
where
  State: RoutableState,
  State.Route: ExpressibleByNilLiteral
{
  public func configureRoutes(
    for publisher: StorePublisher<State.Route>,
    _ configurations: [RouteConfiguration<State.Route>],
    using action: @escaping (RoutingAction<State.Route>) -> Action
  ) -> Cancellable {
    publisher
      .receive(on: UIScheduler.shared)
      .sink { [weak self] route in
        guard let self = self else { return }
        configurations.forEach { configuration in
          self.navigate(
            to: route,
            using: configuration,
            action: action
          )
        }
      }
  }
}

extension ComposableViewController
where
  State: RoutableState,
  State.Route: Taggable,
  State.Route: ExpressibleByNilLiteral
{
  public func configureRoutes(
    for publisher: StorePublisher<State.Route>,
    _ configurations: [RouteConfiguration<State.Route.Tag>],
    using action: @escaping (RoutingAction<State.Route>) -> Action
  ) -> Cancellable {
    publisher
      .receive(on: UIScheduler.shared)
      .sink { [weak self] route in
        guard let self = self else { return }
        configurations.forEach { configuration in
          self.navigate(
            to: route.tag,
            using: configuration,
            action: action
          )
        }
      }
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
    self.getController = childController.initIfNeeded
    self.target = target
  }
  
  var getController: () -> CocoaViewController
  var target: Target
}
#endif
