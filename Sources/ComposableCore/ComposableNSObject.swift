import ComposableArchitecture
import Combine
import Foundation

public typealias ComposableNSObjectOf<R: Reducer> = ComposableObject<
	R.State,
	R.Action
>

open class ComposableNSObject<State, Action>: NSObject, ComposableObjectProtocol {
	public typealias Store = ComposableArchitecture.Store<State, Action>
	public typealias StorePublisher = ComposableArchitecture.StorePublisher<State>
	public typealias Cancellables = Set<AnyCancellable>

	@usableFromInline
	internal let core: ComposableCore<State, Action> = .init()

	@inlinable
	public var store: Store? { core.store }

	@inlinable
	public convenience init(store: Store?) {
		self.init()
		setStore(store)
	}

	@inlinable
	public convenience init(store: ComposableArchitecture.Store<State?, Action>?) {
		self.init()
		setStore(store)
	}

	public override init() {
		super.init()
		core.onStoreWillSet { [weak self] in self?.storeWillSet(from: $0, to: $1) }
		core.onStoreDidSet { [weak self] in self?.storeDidSet(from: $0, to: $1) }
		core.onScope { [weak self] in self?.scope($0) }
		core.onBind { [weak self] in self?.bind($0, into: &$1.wrappedValue) }
	}

	/// Sets a new store with an optional state
	@inlinable
	public func setStore(
		_ store: ComposableArchitecture.Store<State?, Action>?
	) {
		core.setStore(store)
	}

	/// Sets a new store
	@inlinable
	public func setStore(_ store: Store?) {
		core.setStore(store)
	}

	@inlinable
	public func releaseStore() {
		core.releaseStore()
	}

	open func storeWillSet(
		from oldStore: Store?,
		to newStore: Store?
	) {}

	open func storeDidSet(
		from oldStore: Store?,
		to newStore: Store?
	) {}

	open func scope(
		_ store: Store?
	) {}

	open func bind(
		_ state: StorePublisher,
		into cancellables: inout Cancellables
	) {}
}
