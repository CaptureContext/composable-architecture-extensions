import ComposableArchitecture
import Combine
import Foundation

public typealias ComposableNSObjectOf<R: Reducer> = ComposableNSObject<
	R.State,
	R.Action
>

open class ComposableNSObject<State, Action>: NSObject, ComposableObjectProtocol {
	public typealias Core = ComposableCore<State, Action>
	public typealias Store = ComposableArchitecture.Store<State, Action>

	@available(*, deprecated)
	public typealias StorePublisher = ComposableArchitecture.StorePublisher<State>

	@available(*, deprecated, renamed: "Core.Cancellables")
	public typealias Cancellables = Set<AnyCancellable>

	public let core: Core = .init()

	@inlinable
	public var store: Store? { core.store }

	@inlinable
	public convenience init(store: Store) {
		self.init()
		core.setStore(store)
	}

	@inlinable
	public convenience init(store: ComposableArchitecture.Store<State?, Action>) {
		self.init()
		core.setStore(store)
	}

	public override init() {
		super.init()
		core.delegate = self
	}

	/// Sets a new store with an optional state
	@inlinable
	public func setStore(
		_ store: ComposableArchitecture.Store<State?, Action>
	) {
		core.setStore(store)
	}

	/// Sets a new store
	@inlinable
	public func setStore(_ store: Store) {
		core.setStore(store)
	}

	@inlinable
	public func releaseStore() {
		core.releaseStore()
	}

	@inlinable
	open func storeWillSet(
		from oldStore: Store?,
		to newStore: Store?
	) {}

	@inlinable
	open func storeDidSet(
		from oldStore: Store?,
		to newStore: Store?
	) {}

	@inlinable
	open func scope(
		_ store: Store?
	) {}

	@available(
		*, deprecated,
		message: """
		Use `bind(_:into:)` with non-inout Core.Cancellables instead.
		"""
	)
	@inlinable
	open func bind(
		_ store: Store,
		into cancellables: inout Set<AnyCancellable>
	) {}

	@available(
		*, deprecated,
		message: """
		Use `bind(_:into:)` with non-inout Core.Cancellables instead.
		"""
	)
	@inlinable
	open func bind(
		_ store: Store,
		into cancellables: inout Core.Cancellables
	) {
		self.bind(store, into: cancellables)
	}

	@inlinable
	open func bind(
		_ store: Store,
		into cancellables: Core.Cancellables
	) {
		var deprecatedCancellables: Set<AnyCancellable> = []
		self.bind(store, into: &deprecatedCancellables)
		deprecatedCancellables.forEach { $0.store(in: cancellables) }
	}
}

@_spi(Internals)
extension ComposableNSObject: ComposableCoreDelegate {}
