import ComposableArchitecture
import Foundation

public protocol RoutableState {
  typealias RoutingAction = ComposableNavigation.RoutingAction<Route>
  associatedtype Route: Hashable
  var currentRoute: Route { get set }
}
