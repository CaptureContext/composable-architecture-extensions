import CocoaAliases
import ComposableArchitecture
import Prelude
import ComposableCore
import CombineExtensions
import DeclarativeConfiguration
import OrderedCollections

public enum NavigationControllerAction<State: Identifiable, Action> {
  case action(State.ID, Action)
  case push(State)
  case pop
  case popAll
}

extension NavigationControllerAction: Equatable
where State: Equatable, Action: Equatable {}

extension Reducer {
  public func recursiveNavigation<
    ElementState: Identifiable,
    ElementAction
  >(
    state toLocalState: WritableKeyPath<State, IdentifiedArrayOf<ElementState>>,
    action toLocalAction: CasePath<Action, NavigationControllerAction<ElementState, ElementAction>>
  ) -> Reducer {
    Reducer.combine(
      self,
      Reducer<
        IdentifiedArrayOf<ElementState>,
        NavigationControllerAction<ElementState, ElementAction>,
        Void
      > { state, action, _ in
        switch action {
        case let .push(item):
          state.append(item)
          return .none
          
        case .pop:
          if state.isNotEmpty {
            state.removeLast()
          }
          return .none
          
        case .popAll:
          state.removeAll()
          return .none
          
        default:
          return .none
        }
      }.pullback(
        state: toLocalState,
        action: toLocalAction,
        environment: { _ in }
      )
    )
  }
}

open class SwiftUIObservableNavigationController: UINavigationController, ObservableObject {}

public protocol _RecursiveControllerPopSubjectProvider {}
fileprivate protocol _RecursiveControllerPopSubjectProviderInternal {
  var recursiveControllerPopSubject: PassthroughSubject<Void, Never> { get }
}

open class RecursiveNavigationController<
  RootController: CocoaViewController,
  ItemController: CocoaViewController,
  ItemState: Identifiable
>:
  SwiftUIObservableNavigationController,
  _RecursiveControllerPopSubjectProvider,
  _RecursiveControllerPopSubjectProviderInternal
{
  fileprivate let recursiveControllerPopSubject = PassthroughSubject<Void, Never>()
  fileprivate var statesCancellable: Cancellable?
  
  @Handler2<ItemController, ItemState.ID>
  public var onScope
  
  public var shouldAnimateItemControllersUpdate = true
  
  public func bind(_ states: StorePublisher<OrderedSet<ItemState.ID>>) {
    statesCancellable = states.sinkValues(capture { _self, ids in
      _self.updateItemControllersCount(to: ids.count)
      guard let scope = _self.$onScope else { return }
      print(ids)
      zip(_self.itemControllers, ids).forEach(scope)
    })
  }
  
  private func updateItemControllersCount(to count: Int) {
    if itemControllers.count < count {
      while itemControllers.count + 1 < count {
        pushViewController(ItemController(), animated: false)
      }
      pushViewController(
        ItemController(),
        animated: shouldAnimateItemControllersUpdate
      )
    } else if itemControllers.count > count {
      while itemControllers.count - 1 > count {
        _ = popViewController(animated: false)
      }
      _ = popViewController(
        animated: shouldAnimateItemControllersUpdate
      )
    }
  }
  
  public var root: RootController? {
    guard let firstController = viewControllers.first else {
      return nil
    }
    
    guard let root = firstController.as(RootController.self) else {
      preconditionFailure("Type mismatch")
    }
    
    return root
  }
  
  public var itemControllers: [ItemController] {
    return viewControllers.lazy
      .compactMap(cast())
      .filter { controller in
        not(controller.getAssociatedObject(forKey: "composable_controller.is_configured_route").or(false)) &&
          controller != root
      }
  }
  
  public override init(rootViewController: UIViewController) {
    guard let root = rootViewController.as(RootController.self) else {
      preconditionFailure("Type mismatch")
    }
    super.init(rootViewController: root)
  }
  
  public required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }
  
  open override func pushViewController(
    _ viewController: UIViewController,
    animated: Bool
  ) {
    guard not(viewControllers.first.isNil && not(viewController is RootController))
    else { preconditionFailure("Type mismatch") }
    super.pushViewController(viewController, animated: animated)
  }
  
  open override func popViewController(
    animated: Bool
  ) -> UIViewController? {
    let poppedController = super.popViewController(animated: animated)
    if poppedController.is(ItemController.self) {
      if let coordinator = transitionCoordinator, animated {
        coordinator.animate(alongsideTransition: nil) { context in
          if !context.isCancelled {
            self.recursiveControllerPopSubject.send(())
          }
        }
      } else {
        self.recursiveControllerPopSubject.send(())
      }
    }
    return poppedController
  }
  
  open override func setViewControllers(
    _ viewControllers: [UIViewController],
    animated: Bool
  ) {
    guard viewControllers.isEmpty || (viewControllers.first is RootController)
    else { preconditionFailure("Type mismatch") }
    super.setViewControllers(viewControllers, animated: animated)
  }
  
  open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
    let poppedControllers = super.popToRootViewController(animated: animated)
    poppedControllers?
      .reversed().compactMap(cast(to: ItemController.self))
      .forEach { _ in recursiveControllerPopSubject.send(()) }
    return poppedControllers
  }
  
  open override func popToViewController(
    _ viewController: UIViewController,
    animated: Bool
  ) -> [UIViewController]? {
    let poppedControllers = super.popToRootViewController(animated: animated)
    poppedControllers?
      .reversed().compactMap(cast(to: ItemController.self))
      .forEach { _ in recursiveControllerPopSubject.send(()) }
    return poppedControllers
  }
}

extension PublishersProxy where Base: _RecursiveControllerPopSubjectProvider {
  public var recursiveControllerPop: AnyPublisher<Void, Never> {
    return (base as! _RecursiveControllerPopSubjectProviderInternal)
      .recursiveControllerPopSubject.eraseToAnyPublisher()
  }
}
