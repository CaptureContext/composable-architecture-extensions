import CombineExtensions
import ComposableDependencies
import Foundation

public struct StoreSchedulers {
  public init(
    main: NoOptionsSchedulerOf<DispatchQueue>,
    background: GlobalSchedulersClient
  ) {
    self.main = main
    self.background = background
  }
  
  public var main: NoOptionsSchedulerOf<DispatchQueue>
  public var background: GlobalSchedulersClient
}

extension StoreSchedulers {
  public static var live: StoreSchedulers = .init(
    main: .eventHandling,
    background: .live
  )
}

private enum StoreSchedulersKey: DependencyKey {
  public static var defaultValue: StoreSchedulers { .live }
}

extension Dependencies {
  public var storeSchedulers: StoreSchedulers {
    get { self[StoreSchedulersKey.self] }
    set { self[StoreSchedulersKey.self] = newValue }
  }
}
