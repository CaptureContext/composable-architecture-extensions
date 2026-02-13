import ComposableArchitecture
import Combine
import Foundation

public final class ComposableCore<State, Action>: ComposableObjectProtocol {
	public typealias Store = ComposableArchitecture.Store<State, Action>
	public typealias Cancellables = ComposableCoreCancellables

	public var core: ComposableCore<State, Action> { self }

	private var cachedStore: Store?

	@_ComposableCore_OptionallyUIBindable
	private(set) public var store: Store?

	public let cancellables: Cancellables = .init()

	@_spi(Internals)
	public weak var delegate: (any ComposableCoreDelegate<State, Action>)?

	public init() {}

	public func setStore(
		_ store: ComposableArchitecture.Store<State?, Action>
	) {
		self.cancellables._withLock {
			$0.store?.cancel()
		}

		let token = store.uncheckedSendableIfLet(
			then: { [weak self] store in
				self?._setStore(store)
			},
			else: { [weak self] in
				self?.releaseStore()
			}
		)

		self.cancellables._withLock {
			$0.store = token.value
		}
	}

	public func setStore(_ store: Store) {
		self.cancellables._withLock { $0.store?.cancel() }
		self._setStore(store)
	}

	public func releaseStore() {
		self.cancellables._withLock { $0.store?.cancel() }
		self._setStore(Store?.none)
	}

	@_spi(Internals)
	public func setStoreFromCache() {
		let store = self.cachedStore
		self.cachedStore = nil
		self.setStore(store)
	}

	@usableFromInline
	func _setStore(
		_ store: Store?,
	) {
		switch delegate?.setStoreMode {
		case .cache:
			self.cachedStore = store
		default:
			self.__setStore(store)
		}
	}

	@usableFromInline
	func __setStore(
		_ store: Store?,
	) {
		let oldStore = self.store
		self.delegate?.storeWillSet(from: oldStore, to: store)
		self.store = store
		self.delegate?.storeDidSet(from: oldStore, to: store)
		self.delegate?.scope(store)
		self.bind()
	}

	@_spi(Internals)
	public func bind() {
		guard let store else { return }
		self.cancellables._withLock {
			self.delegate?.bind(store, into: $0)
		}
	}
}

extension Store {
	func uncheckedSendableIfLet<Wrapped>(
		then unwrap: @escaping (_ store: Store<Wrapped, Action>) -> Void,
		else: @escaping () -> Void = {}
	) -> UncheckedSendable<(any Cancellable)> where State == Wrapped? {
		UncheckedSendable(ifLet(then: unwrap, else: `else`))
	}
}
