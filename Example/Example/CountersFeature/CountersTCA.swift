import ComposableExtensions
import CocoaExtensions
import SwiftUI

struct CountersState: Equatable, Identifiable, RoutableState {
  var id: UUID = .init()
  var counters: IdentifiedArrayOf<CounterState> = []
  var currentRoute: CountersRoute?
}

enum CountersRoute: TaggedRoute, Hashable {
  case counter(CounterState.ID)
  
  enum Tag: Hashable {
    case counter
  }
  
  var tag: Tag {
    switch self {
    case .counter:
      return .counter
    }
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(tag)
  }
}

enum CountersAction: Equatable, RouterAction {
  case counter(CounterState.ID, CounterAction)
  case addCounter(CounterState)
  case removeCounter(CounterState.ID)
  case router(RoutingAction<CountersRoute?>)
}

class CountersEnvironment: ComposableEnvironment {
  @DerivedEnvironment
  var counter: CounterEnvironment
}

let countersReducer = Reducer.combine(
  _counterReducer,
  _baseCountersReducer
)

private let _baseCountersReducer = Reducer<
  CountersState,
  CountersAction,
  CountersEnvironment
> { state, action, environment in
  switch action {
  case let .addCounter(counter):
    state.counters.append(counter)
    return .none
    
  case let .removeCounter(id):
    state.counters.remove(id: id)
    return .none
    
  default:
    return .none
  }
}.routing()

private let _counterReducer: Reducer<
  CountersState,
  CountersAction,
  CountersEnvironment
> = counterReducer.forEach(
  state: \CountersState.counters,
  action: /CountersAction.counter
)

struct CountersView: View {
  let navigationController: SwiftUIObservableNavigationController?
  
  init(_ store: Store<CountersState, CountersAction>) {
    self.store = store
    self.navigationController = nil
  }
  
  init(
    _ store: Store<CountersState, CountersAction>,
    navigationController: SwiftUIObservableNavigationController?
  ) {
    self.store = store
    self.navigationController = navigationController
  }
  
  let store: Store<CountersState, CountersAction>
  
  var body: some View {
    if let controller = navigationController {
      content.environmentObject(controller)
    } else {
      content
    }
  }
  
  var content: some View {
    WithViewStore(store) { viewStore in
      List {
        ForEach(viewStore.counters) { counter in
          Button(counter.value.description) {
            viewStore.send(.route(to: .counter(counter.id)))
          }
        }.onDelete(perform: { indexSet in
          indexSet.forEach { index in
            viewStore.send(
              .removeCounter(viewStore.counters[index].id),
              animation: .easeInOut
            )
          }
        })
      }.overlay(
        Button(action: {
          viewStore.send(
            .addCounter(CounterState()),
            animation: .easeOut
          )
        }) {
          Image(systemName: "plus")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .padding(12)
            .background(Circle().fill(Color(.systemBlue)))
        }
        .shadow(radius: 10, x: 2, y: 5)
        .padding()
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .bottomTrailing
        )
      )
    }
  }
}

extension CountersView {
  final class Controller: ComposableViewController<
    CountersState,
    CountersAction
  > {
    @CustomView
    var contentView: UIHostingView<CountersView?>
    
    @ComposableChildController
    var counterController: CounterView.Controller?
    
    override func scope(
      _ store: Core.Store?
    ) {
      contentView.rootView = store.map { store in
        CountersView(
          store,
          navigationController: navigationController.as(SwiftUIObservableNavigationController.self)
        )
      }
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      contentView.backgroundColor = .white
    }
    
    override func bind(
      _ state: Core.StorePublisher,
      into cancellables: inout Core.Cancellables
    ) {
      state.currentRoute
        .sinkValues(capture { _self, route in
          guard case let .counter(id) = route else {
            _self._counterController.releaseStore()
            return
          }
          _self._counterController.setStore(
            _self.core.store?._scope(
              state: { $0.counters[id: id] },
              action: { .counter(id, $0) }
            )
          )
        })
        .store(in: &cancellables)
      
      configureRoutes(
        for: state.currentRoute,
        [
          .associate(_counterController, with: .counter)
        ],
        using: Action.router
      )
      .store(in: &cancellables)
    }
  }
}

enum CountersPreviews: PreviewProvider {
  static var previews: some View {
    CountersView(
      Store(
        initialState: CountersState(),
        reducer: countersReducer,
        environment: CountersEnvironment()
      )
    )
  }
}
