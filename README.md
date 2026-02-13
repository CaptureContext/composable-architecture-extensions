# composable-architecture-extensions

[![CI](https://github.com/capturecontext/composable-architecture-extensions/actions/workflows/ci.yml/badge.svg)](https://github.com/capturecontext/composable-architecture-extensions/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fcomposable-architecture-extensions%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/capturecontext/composable-architecture-extensions) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fcomposable-architecture-extensions%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/capturecontext/composable-architecture-extensions)

Extensions for [TCA](https://github.com/pointfreeco/swift-composable-architecture).

> [!NOTE]
> 
> The package is early beta (feel free suggest your improvements [here](https://github.com/capturecontext/composable-architecture-extensions/discussions/1))

## Table of contents

- [Motivation](#motivation)
- [Products](#products)
  - [ComposableCore](#composablecore)
  - [ComposableCocoa](#composablecocoa)
  - [ComposableSwiftUI](#composableswiftui)
  - [ComposableExtensions](#composableextensions)
- [Installation](#installation)
- [License](#license)

## Products

### ComposableCore

#### ComposableCore

Core manages underlying optional store, enables users to design UI components with lazy logical bindings. This approach allows to derive configuration logic out of initializers and treat components (primarilly UI-components) as containers that can exist without any logic.

#### Composable(NS)Object

Is a generic object driven by the core, since Swift doesn't allow inheritance from multiple classes, not every class that conforms to `ComposableObjectProtocol` can be downcasted to `ComposableObject`, good example is `ComposableObject` and `ComposableNSObject` classes, which are not interchangeable. Provides helpers for binding and scoping cores.

```swift
class ExampleObject: ComposableObjectOf<ExampleFeature> {
  override func scope(_ store: Store?) {
    super.scope(store)
    
    childObject.core.setStore(store?.scope(
    	state: \.child.state,
    	action: \.child.action
    ))
  }
  
  override func bind(
    _ store: Store,
    into cancellables: Core.Cancellables
  ) {
    super.bind(store, into: cancellables)
    
    // This API is not yet available
    store.observe(\.text)
      .assign(to: self, \.text)
      .store(in: cancellables)
  }
}
```

#### PullbackReducer

Pullbacks improve Reducers composition by replacing switch statements.

```swift
Pullback(\.path.to.child.action) { state in 
  return .send(.parentAction)
}

Pullback(\.path.to.child.action) { state, childAction in 
  return .send(.parentAction)
}

Pullback(\.path.to.children, action: \.child.action) { state, id, childAction in 
  return .send(.parentAction)
}
```

#### OnChangeReducer

Allows to track changes in derived states.

```swift
SomeReducer().onChange(of: \.localState) { state, oldValue, newValue in 
  return .send(.parentAction)
}
```

#### ForEachReducer

Indexed ForEach is useful when working with arrays

```swift
._forEach(
  \.arrayOfElements, // non-identified
  action: \.pathToAction,
  element: { ElementReducer() }
)
```

Labeled ForEach is useful for multiline ergonomics

```swift
forEach(
  state: \.arrayOfElements,
  action: \.pathToAction,
  element: { ElementReducer() }
)

._forEach(
  state: \.arrayOfElements, // non-identified
  action: \.pathToAction,
  element: { ElementReducer() }
)
```

### ComposableCocoa

> [!NOTE]
>
> _The product is compatible with non-Apple platforms, however it uses conditional compilation, so **APIs are only available on Apple platforms**_

#### ComposableCocoaView

`CustomCocoaView` that is also `ComposableObjectProtocol`

```swift
public class ExampleCocoaView: ComposableCocoaViewOf<ExampleFeature> {
  // Initial configuration
  override public func _init() {
    super._init()
  }
  
  // Action example
  func onTap() {
    core.store?.send(.tap)
  }
  
  // Scoping
  override public func scope(_ store: Store?) {
    super.scope(store)
    
    childView.core.setStore(store?.scope(
      state: \.child.state,
      action: \.child.action
    ))
  }
  
  // Binding
  override public func bind(
    _ store: Store,
    into cancellables: Core.Cancellables
  ) {
    super.bind(store, into: cancellables)
    
    // This API is not yet available
    store.observe(\.text)
      .assign(to: label, \.text)
      .store(in: cancellables)
  }
}
```

#### ComposableViewController

`CustomCocoaViewController` that is also `ComposableObjectProtocol`. Composable controllers won't scope/bind values untill managed object is loaded (view for ViewControllers, window for WindowControllers). API is similar to `ComposableCocoaView`.

- `ComposableTabViewController` is also available on `iOS`
- `ComposableWindowController` is available on `macOS`

### ComposableSwiftUI

> [!NOTE]
>
> _The product is compatible with non-Apple platforms, however it uses conditional compilation, so **APIs are only available on Apple platforms**_

#### ComposableView

Protocol for SwiftUI views that improves composability. Composable views can only be initialized with optional stores.

```swift
public struct ExampleView: ComposableView {
  @UIBindable
  private var store: StoreOf<ExampleFeature>
  
  public init(_ store: StoreOf<ExampleFeature>) {
    self.store = store
  }
  
  public var body: some View { /*...*/ }
}
```

### ComposableExtensions

Umbrella product that exports everything.

## Installation

### Basic

You can add `composable-architecture-extensions` to an Xcode project by adding it as a package dependency

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/composable-architecture-extensions"`](https://github.com/capturecontext/composable-architecture-extensions) into the package repository URL text field
3. Choose products you need to link to your project.

### Recommended

If you use SwiftPM for your project structure, add `composable-architecture-extensions` dependency to your package file. 

```swift
.package(
  url: "https://github.com/capturecontext/composable-architecture-extensions.git", 
  .upToNextMinor("0.3.0-alpha.1")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "<#Product#>", 
  package: "composable-architecture-extensions"
)
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
