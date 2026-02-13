#if os(macOS)
import Combine
import CocoaExtensions
@_spi(Internals) import ComposableCore

public typealias ComposableWindowControllerProtocolOf<R: Reducer> = ComposableWindowControllerProtocol<
	R.State,
	R.Action
>

public protocol ComposableWindowControllerProtocol<State, Action>:
	NSWindowController,
	ComposableObjectProtocol
{}

public typealias ComposableWindowControllerOf<R: Reducer> = ComposableWindowController<
	R.State,
	R.Action
>

@_spi(Internals)
extension ComposableWindowController: ComposableCoreDelegate {}

open class ComposableWindowController<
  State,
  Action
>:
  CustomCocoaWindowController,
	ComposableObjectProtocol,
	ComposableWindowControllerProtocol
{
	public typealias Core = ComposableCore<State, Action>
	public typealias Store = ComposableArchitecture.Store<State, Action>

	@available(*, deprecated)
	public typealias StorePublisher = ComposableArchitecture.StorePublisher<State>

	@available(*, deprecated, renamed: "Core.Cancellables")
	public typealias Cancellables = Set<AnyCancellable>

	public let core: Core = .init()

	@available(*, deprecated, renamed: "core.store")
	@inlinable
	public var store: Store? { core.store }

	@inlinable
	public convenience init(store: Store?) {
		self.init()
		core.setStore(store)
	}

	@inlinable
	public convenience init(store: ComposableArchitecture.Store<State?, Action>?) {
		self.init()
		core.setStore(store)
	}

	override open func _init() {
		super._init()
		self.core.delegate = self
	}

	open override func windowDidLoad() {
		super.windowDidLoad()
		self.core.setStoreFromCache()
	}

	@_spi(Internals)
	public var setStoreMode: ComposableCoreSetStoreMode {
		isWindowLoaded ? .update : .cache
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
#endif
