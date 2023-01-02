import ComposableArchitecture
import Foundation

public protocol RoutableAction<Route> {
  associatedtype Route: Hashable

  @inlinable
  static func router(_: RoutingAction<Route>) -> Self
}

extension RoutableAction {
  @inlinable
  public static func navigate(to route: Route) -> Self {
    return .router(.navigate(to: route))
  }
}

public enum RoutingAction<Route: Hashable>: Equatable {
  case navigate(to: Route)

  @inlinable
  public var route: Route {
    switch self {
    case let .navigate(to: route):
      return route
    }
  }
}

extension RoutingAction where Route: ExpressibleByNilLiteral {
  @inlinable
  public static var dismiss: RoutingAction { .navigate(to: nil) }
}
