import ComposableArchitecture
import Foundation

public protocol RouterAction {
  associatedtype Route: Hashable
  static func router(_: RoutingAction<Route>) -> Self
}

extension RouterAction {
  public static func navigate(to route: Route) -> Self {
    return .router(.navigate(to: route))
  }
}

public enum RoutingAction<Route: Hashable>: Equatable {
  case navigate(to: Route)
  public var route: Route {
    switch self {
    case let .navigate(to: route):
      return route
    }
  }
}

extension RoutingAction where Route: ExpressibleByNilLiteral {
  public static var dismiss: RoutingAction { .navigate(to: nil) }
}
