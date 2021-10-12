import ComposableArchitecture
import Foundation

public protocol RouterAction: Equatable {
  associatedtype Route: Hashable
  static func router(_: RoutingAction<Route>) -> Self
}

extension RouterAction {
  public static func route(to route: Route) -> Self {
    return .router(.route(to: route))
  }
}

public enum RoutingAction<Route: Hashable>: Equatable {
  case route(to: Route)
  public var route: Route {
    switch self {
    case let .route(to: route):
      return route
    }
  }
}

extension RoutingAction where Route: ExpressibleByNilLiteral {
  public static var dismiss: RoutingAction { .route(to: nil) }
}
