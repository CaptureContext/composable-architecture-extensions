import ComposableExtensions
import SwiftUI
import CocoaExtensions

struct CounterState: Equatable, Identifiable {
  var id: UUID = .init()
  var value: Int = 0
}

enum CounterAction: Equatable {
  case increment
  case decrement
  case random
  case save
  case moreCounters
}

class CounterEnvironment: ComposableEnvironment {
  @Dependency(\.randomIntGenerator)
  var random
}

let counterReducer = Reducer<
  CounterState,
  CounterAction,
  CounterEnvironment
> { state, action, environment in
  switch action {
  case .increment:
    state.value += 1
    return .none
    
  case .decrement:
    state.value -= 1
    return .none
    
  case .random:
    state.value = environment.randomIntGenerator.generate(in: -10...10)
    return .none
    
  default:
    return .none
  }
}
  

struct CounterView: View {
  init(_ store: Store<CounterState, CounterAction>) {
    self.store = store
  }
  
  let store: Store<CounterState, CounterAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Spacer()
        HStack {
          Button("-") { viewStore.send(.decrement) }
          Text(viewStore.value.description)
            .padding()
          Button("+") { viewStore.send(.increment) }
        }
        Button("Random") { viewStore.send(.random) }
          .padding()
        Button("Save") { viewStore.send(.save) }
          .padding()
        Spacer()
        Button(action: { viewStore.send(.moreCounters) }) {
          Text("More counters")
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(.systemBlue))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding([.horizontal, .bottom])
        }
      }
    }
  }
}

extension CounterView {
  class Controller: ComposableViewController<
    CounterState,
    CounterAction
  > {
    @CustomView
    var contentView: UIHostingView<CounterView?>
    
    override func scope(_ store: Store<CounterState, CounterAction>?) {
      super.scope(store)
      self.contentView.rootView = store.map(CounterView.init)
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      self.contentView.backgroundColor = .white
    }
  }
}

enum CounterPreviews: PreviewProvider {
  static var previews: some View {
    CounterView(
      Store(
        initialState: CounterState(value: 0),
        reducer: counterReducer,
        environment: CounterEnvironment()
      )
    )
  }
}
