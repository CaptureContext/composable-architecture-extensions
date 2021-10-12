import ComposableExtensions
import CocoaExtensions
import SwiftUI

struct MainState: Equatable, RoutableState {
  var counters: CountersState = .init()
  var favoriteNumbers: [Int] = []
  
  @BindableState
  var currentRoute: MainRoute = .counters
  var recursiveCounters: IdentifiedArrayOf<CountersState> = []
}

enum MainRoute: Hashable {
  case counters
  case favorites
}

enum MainAction: Equatable, RouterAction, BindableAction {
  case recursiveCounters(CountersState.ID, CountersAction)
  case counters(CountersAction)
  case navigation(NavigationControllerAction<CountersState, CountersAction>)
  case router(RoutingAction<MainRoute>)
  case binding(BindingAction<MainState>)
}

class MainEnvironment: ComposableEnvironment {
  @DerivedEnvironment
  var counters: CountersEnvironment
}

let mainReducer = Reducer.combine(
  _recursiveCountersReducer,
  _countersReducer,
  _baseMainReducer
)

private let _baseMainReducer = Reducer<
  MainState,
  MainAction,
  MainEnvironment
> { state, action, environment in
  switch action {
  case .counters(.counter(_, .moreCounters)),
       .recursiveCounters(_, .counter(_, .moreCounters)):
    return Effect(value: .navigation(.push(CountersState())))
    
  case let .counters(.counter(id, .save)):
    state.counters.counters[id: id].map { counter in
      state.favoriteNumbers.append(counter.value)
    }
    return .none
    
  case let .recursiveCounters(id, .counter(counterID, .save)):
    state
      .recursiveCounters[id: id]
      .flatMap { $0.counters[id: counterID] }
      .map { counter in
        state.favoriteNumbers.append(counter.value)
      }
    return .none
    
  default:
    return .none
  }
}
.binding()
.routing()
.recursiveNavigation(
  state: \MainState.recursiveCounters,
  action: /MainAction.navigation
)

private let _countersReducer: Reducer<
  MainState,
  MainAction,
  MainEnvironment
> = countersReducer.pullback(
  state: \MainState.counters,
  action: /MainAction.counters
)

private let _recursiveCountersReducer: Reducer<
  MainState,
  MainAction,
  MainEnvironment
> = countersReducer.forEach(
  state: \MainState.recursiveCounters,
  action: /MainAction.recursiveCounters
)

final class RecursiveCountersViewController: ComposableViewController<
  MainState,
  MainAction
> {
  let navigation = RecursiveNavigationController<
    CountersView.Controller,
    CountersView.Controller,
    CountersState
  >(rootViewController: CountersView.Controller())
  
  override func scope(_ store: Core.Store?) {
    navigation.root?.core.setStore(
      store?._scope(
        state: \.counters,
        action: MainAction.counters
      )
    )
    
    navigation.onScope { controller, id in
      guard let store = store else {
        controller.core.releaseStore()
        return
      }
      controller.core.setStoreIfNeeded(
        store._scope(
          state: { $0.recursiveCounters[id: id] },
          action: { .recursiveCounters(id, $0) }
        )
      )
    }
  }
  
  override func bind(
    _ state: Core.StorePublisher,
    into cancellables: inout Core.Cancellables
  ) {
    navigation.bind(state[dynamicMember: \.recursiveCounters.ids])
    
    navigation.publishers.recursiveControllerPop
      .sinkValues(capture { _self in
        _self.core.send(.navigation(.pop))
      })
      .store(in: &cancellables)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(navigation.view)
    navigation.navigationBar.isTranslucent = false
    navigation.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      navigation.view.topAnchor.constraint(equalTo: view.topAnchor),
      navigation.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      navigation.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      navigation.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
}

struct MainView: View {
  init(_ store: Store<MainState, MainAction>) {
    self.store = store
  }
  
  let store: Store<MainState, MainAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      TabView(selection: viewStore.binding(\.$currentRoute)) {
        CocoaComponent(RecursiveCountersViewController()) { controller, context in
          guard controller.core.store.isNil else { return }
          controller.core.setStore(store)
        }
        .tabItem { Text("Counters") }
        .tag(MainRoute.counters)
        
        List {
          ForEach(viewStore.favoriteNumbers, id: \.self) { value in
            Text(value.description)
          }
        }
        .tabItem { Text("Favorites") }
        .tag(MainRoute.favorites)
      }
    }
  }
}
