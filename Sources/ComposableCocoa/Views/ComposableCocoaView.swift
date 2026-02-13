#if !os(watchOS)
import ComposableArchitecture
import Combine
import CocoaAliases
import CocoaExtensions
@_spi(Internals) import ComposableCore

public typealias ComposableCocoaViewOf<
	Feature: Reducer
> = ComposableCocoaView<
	Feature.State,
	Feature.Action
>

public protocol ComposableCocoaViewProtocol<
	State,
	Action
>: CocoaView, ComposableObjectProtocol {}

@_spi(Internals)
extension ComposableCocoaView: ComposableCoreDelegate {}

open class ComposableCocoaView<State, Action>:
	CustomCocoaView,
	ComposableObjectProtocol,
	ComposableCocoaViewProtocol
{
	public let core: Core = .init()

	public typealias Store = ComposableArchitecture.Store<State, Action>
	public typealias Core = ComposableCore<State, Action>

	open override func _init() {
		super._init()
		self.core.delegate = self
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
