#if !os(watchOS) && canImport(SwiftUI)
import ComposableArchitecture
import Combine
import CocoaAliases
import CocoaExtensions
import SwiftUI
@_spi(Internals) import ComposableCore

public typealias ComposableHostingControllerOf<
	Feature: Reducer,
	Content: View
> = ComposableHostingController<
	Feature.State,
	Feature.Action,
	Content
>

@_spi(Internals)
extension ComposableHostingController: ComposableCoreDelegate {}

open class ComposableHostingController<State, Action, Content: View>:
	CustomHostingController<Content>,
	ComposableObjectProtocol,
	ComposableViewControllerProtocol
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

	open override func _init() {
		super._init()
		self.core.delegate = self
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		self.core.setStoreFromCache()
	}

	@_spi(Internals)
	public var setStoreMode: ComposableCoreSetStoreMode {
		return isViewLoaded ? .update : .cache
	}

	@inlinable
	open func scope(
		_ store: Store?
	) {}

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
