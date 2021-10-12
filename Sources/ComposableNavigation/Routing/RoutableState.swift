import ComposableArchitecture
import Foundation

public protocol RoutableState {
  typealias RoutingAction = ComposableNavigation.RoutingAction<Route>
  associatedtype Route: Hashable
  var currentRoute: Route { get set }
}

public protocol TaggedRoute: Equatable {
  associatedtype Tag: Hashable
  var tag: Tag { get }
}

extension Optional: TaggedRoute where Wrapped: TaggedRoute {
  public typealias Tag = Optional<Wrapped.Tag>
  public var tag: Tag { self?.tag }
}
