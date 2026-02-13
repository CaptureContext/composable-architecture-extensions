import ComposableArchitecture
import Foundation
import Combine

public typealias ComposableObjectProtocolOf<R: Reducer> = ComposableObjectProtocol<
	R.State,
	R.Action
>

#if swift(<5.10)
@MainActor(unsafe)
#else
@preconcurrency@MainActor
#endif
public protocol ComposableObjectProtocol<State, Action> {
	associatedtype State
	associatedtype Action

	typealias Store = ComposableArchitecture.Store<State, Action>
	typealias Core = ComposableCore<State, Action>

	@available(*, deprecated, renamed: "Core.Cancellables")
	typealias Cancellables = Core.Cancellables

	var core: Core { get }

	func setStore(_ store: ComposableArchitecture.Store<State?, Action>)
	func setStore(_ store: Store)
	func releaseStore()
}

extension ComposableObjectProtocol {
	public func setStore(_ store: ComposableArchitecture.Store<State?, Action>) {
		core.setStore(store)
	}

	public func setStore(_ store: Store) {
		core.setStore(store)
	}

	public func releaseStore() {
		core.releaseStore()
	}

	@_disfavoredOverload
	public func setStore(_ store: ComposableArchitecture.Store<State?, Action>?) {
		if let store { setStore(store) } else { releaseStore() }
	}

	@_disfavoredOverload
	public func setStore(_ store: Store?) {
		if let store { setStore(store) } else { releaseStore() }
	}
}
