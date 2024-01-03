#if canImport(UIKit) && !os(watchOS)
import CombineNavigation
import ComposableArchitecture
import Combine

extension ComposableViewControllerProtocol where Self: RoutingController {
	public func navigationStack<
		StackElementState,
		StackElementAction
	>(
		state toStackState: KeyPath<State, StackState<StackElementState>>,
		action toStackAction: CaseKeyPath<Action, StackAction<StackElementState, StackElementAction>>,
		switch destination: @escaping (Destinations, StackElementState) -> any _StackDestinationProtocol<StackElementID>,
		file: StaticString = #file,
		line: UInt = #line
	) -> Cancellable {
		guard let store = store else {
			assertionFailure("""
				Store was missing on \(#function) call in \
				\(file) | \(line)
				"""
			)

			return AnyCancellable {}
		}

		return navigationStack(
			store.publisher.map(toStackState),
			ids: \.ids,
			route: { $0[id: $1] },
			switch: destination,
			onPop: { [weak self] ids in
				guard
					let id = ids.first,
					let store = self?.store
				else { return }

				store.send(toStackAction.callAsFunction(.popFrom(id: id)))
			}
		)
	}
}

extension ComposableViewControllerProtocol where Self: RoutingController {
	/// Subscribes on publisher of navigation destination state
	@inlinable
	public func navigationDestination(
		isPresented toIsPresented: KeyPath<State, Bool>,
		destination: _TreeDestinationProtocol,
		popAction: Action,
		file: StaticString = #file,
		line: UInt = #line
	) -> AnyCancellable {
		guard let store = store else {
			assertionFailure("""
				Store was missing on \(#function) call in \
				\(file) | \(line)
				"""
			)

			return AnyCancellable {}
		}

		return navigationDestination(
			toIsPresented,
			isPresented: store.publisher.map(toIsPresented),
			destination: destination,
			onPop: { [weak self] in
				self?.store?.send(popAction)
			}
		)
	}

	/// Subscribes on publisher of navigation destination state
	@inlinable
	public func navigationDestination<Route>(
		state toDestinationState: KeyPath<State, PresentationState<Route>>,
		switch destination: @escaping (Destinations, Route) -> _TreeDestinationProtocol,
		popAction: Action,
		file: StaticString = #file,
		line: UInt = #line
	) -> AnyCancellable {
		guard let store = store else {
			assertionFailure("""
				Store was missing on \(#function) call in \
				\(file) | \(line)
				"""
			)

			return AnyCancellable {}
		}

		return navigationDestination(
			store.publisher.map(toDestinationState.appending(path: \.wrappedValue)),
			switch: destination,
			onPop: { [weak self] in
				self?.store?.send(popAction)
			}
		)
	}
}

extension ComposableViewControllerProtocol where Self: RoutingController {
	/// Subscribes on publisher of navigation destination state
	@inlinable
	public func presentationDestination(
		isPresented toIsPresented: KeyPath<State, Bool>,
		destination: _PresentationDestinationProtocol,
		dismissAction: Action,
		file: StaticString = #file,
		line: UInt = #line
	) -> AnyCancellable {
		guard let store = store else {
			assertionFailure("""
				Store was missing on \(#function) call in \
				\(file) | \(line)
				"""
			)

			return AnyCancellable {}
		}

		return presentationDestination(
			toIsPresented,
			isPresented: store.publisher.map(toIsPresented),
			destination: destination,
			onDismiss: { [weak self] in
				self?.store?.send(dismissAction)
			}
		)
	}

	/// Subscribes on publisher of navigation destination state
	@inlinable
	public func presentationDestination<Route>(
		state toDestinationState: KeyPath<State, PresentationState<Route>>,
		switch destination: @escaping (Destinations, Route) -> _PresentationDestinationProtocol,
		dismissAction: Action,
		file: StaticString = #file,
		line: UInt = #line
	) -> AnyCancellable {
		guard let store = store else {
			assertionFailure("""
				Store was missing on \(#function) call in \
				\(file) | \(line)
				"""
			)

			return AnyCancellable {}
		}

		return presentationDestination(
			store.publisher.map(toDestinationState.appending(path: \.wrappedValue)),
			switch: destination,
			onDismiss: { [weak self] in
				self?.store?.send(dismissAction)
			}
		)
	}
}
#endif
