#if canImport(UIKit) && !os(watchOS)
import ComposableArchitecture
import ComposableNavigation
import Combine
import CocoaAliases
import FoundationExtensions
import CombineNavigation

extension Cancellable {
  @usableFromInline
  func store(in cancellable: inout Cancellable?) {
    cancellable = self
  }
}

extension ComposableViewController {
  @inlinable
  public func configureRoutes<
    Route: Hashable & ExpressibleByNilLiteral
  >(
    for publisher: StorePublisher<Route>,
    routes: [RouteConfiguration<Route>],
    dismissAction: Action
  ) -> Cancellable {
    self.configureRoutes(
      for: publisher,
      routes: routes,
      onDismiss: { [weak self] in
        self?.core.send(dismissAction)
      }
    )
  }
}

#endif
