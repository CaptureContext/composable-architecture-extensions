import ComposableArchitecture
import Combine
import FunctionalClosures
import FoundationExtensions

public final class ComposableCore<State, Action>: ComposableObjectProtocol {
	public typealias Store = ComposableArchitecture.Store<State, Action>
	public typealias StorePublisher = ComposableArchitecture.StorePublisher<State>
	public typealias Cancellables = Set<AnyCancellable>

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

	public init() {}

	@usableFromInline
	internal let lock = NSLock()

	@usableFromInline
	internal var storeCancellable: Cancellable?

	@usableFromInline
	internal var stateCancellables: Cancellables = []

	@inlinable
	@Handler2<Store?, Store?>
	public var onStoreWillSet

	@inlinable
	@Handler2<Store?, Store?>
	public var onStoreDidSet

	@inlinable
	@Handler1<Store?>
	public var onScope

	@inlinable
	@Handler2<StorePublisher, Reference<Cancellables>>
	public var onBind

	@usableFromInline
	internal var _store: Store?

	public var store: Store? { _store }

	@inlinable
	internal func subscribeToStateChanges() {
		lock.withLock {
			stateCancellables.removeAll()
			if let statePublishser = store?.publisher {
				bind(statePublishser)
			}
		}
	}

	/// Sets a new store with an optional state
	@inlinable
	public func setStore(
		_ store: ComposableArchitecture.Store<State?, Action>?
	) {
		guard let store = store else { return releaseStore() }

		storeCancellable = store.ifLet(
			then: { [weak self] store in
				self?.setStore(store)
			},
			else: { [weak self] in
				self?.releaseStore()
			}
		)
	}

	/// Sets a new store
	@inlinable
	public func setStore(_ store: Store?) {
		self.storeCancellable = nil
		let oldStore = self.store
		self.storeWillSet(from: oldStore, to: store)
		self._store = store
		self.scope(store)
		self.subscribeToStateChanges()
		self.storeDidSet(from: oldStore, to: store)
	}

	@inlinable
	public func releaseStore() {
		setStore(Store?.none)
	}

	@usableFromInline
	internal func storeWillSet(
		from oldStore: Store?,
		to newStore: Store?
	) {
		_onStoreWillSet(oldStore, newStore)
	}

	@usableFromInline
	internal func storeDidSet(
		from oldStore: Store?,
		to newStore: Store?
	) {
		_onStoreDidSet(oldStore, newStore)
	}

	@usableFromInline
	internal func scope(
		_ store: Store?
	) {
		_onScope(store)
	}

	@usableFromInline
	internal func bind(_ state: StorePublisher) {
		_onBind(state, .object(self, keyPath: \.stateCancellables))
	}
}
