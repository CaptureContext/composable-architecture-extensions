#if !os(watchOS)
import CocoaExtensions
import ComposableCore
import CocoaAliases
import Combine
import CombineNavigation

public typealias ComposableViewControllerProtocolOf<R: Reducer> = ComposableViewControllerProtocol<
	R.State,
	R.Action
>

public protocol ComposableViewControllerProtocol<State, Action>:
  CocoaViewController,
  ComposableObjectProtocol
{}

public typealias ComposableViewControllerOf<R: Reducer> = ComposableViewController<
	R.State,
	R.Action
>

open class ComposableViewController<
  State,
  Action
>: CustomCocoaViewController, ComposableViewControllerProtocol {
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
		core.setStore(store)
	}

	@inlinable
	public convenience init(store: ComposableArchitecture.Store<State?, Action>?) {
		self.init()
		core.setStore(store)
	}

	override open func _init() {
		super._init()
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

#if canImport(UIKit) && !os(macOS)
extension ComposableViewControllerProtocol {
	public func navigationStack<
		StackElementState,
		StackElementAction
	>(
		state toStackState: KeyPath<State, StackState<StackElementState>>,
		action toStackAction: CaseKeyPath<Action, StackAction<StackElementState, StackElementAction>>,
		switch destination: @escaping (StackElementState) -> any GrouppedDestinationProtocol<StackElementID>,
		file: StaticString = #file,
		line: UInt = #line
	) -> Cancellable {
		guard let store = store else {
			assertionFailure("""
			Store was missing on \(#function) call in \
			\(file) | \(line)
			""")

			return AnyCancellable {}
		}

		return navigationStack(
			store.publisher.map(toStackState).removeDuplicates(by: { $0.ids == $1.ids }),
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
#endif
#endif
