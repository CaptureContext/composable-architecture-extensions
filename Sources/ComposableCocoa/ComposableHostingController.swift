#if !os(watchOS)
import SwiftUI
import CocoaAliases
import Combine
import CocoaExtensions
import ComposableArchitecture

public protocol ComposableHostingControllerProtocol<ContentView>:
	CustomHostingController<Self.ContentView?>,
	ComposableObjectProtocol
where State == ContentView.State, Action == ContentView.Action {
	associatedtype ContentView: ComposableView
}

public class ComposableHostingController<ContentView: ComposableView>:
	CustomHostingController<ContentView?>,
	ComposableViewControllerProtocol
{
	public typealias State = ContentView.State
	public typealias Action = ContentView.Action
	public typealias Store = ComposableArchitecture.Store<State, Action>
	public typealias StorePublisher = ComposableArchitecture.StorePublisher<State>
	public typealias Cancellables = Set<AnyCancellable>

	@usableFromInline
	internal let core: ComposableCore<State, Action> = .init()

	@inlinable
	public var store: Store? { core.store }

	@inlinable
	public convenience init(store: Store?) {
		self.init(rootView: nil)
		core.setStore(store)
	}

	@inlinable
	public convenience init(store: ComposableArchitecture.Store<State?, Action>?) {
		self.init(rootView: nil)
		core.setStore(store)
	}

	override open func _init() {
		super._init()
		core.onStoreWillSet { [weak self] in self?.storeWillSet(from: $0, to: $1) }
		core.onStoreDidSet { [weak self] in self?.storeDidSet(from: $0, to: $1) }
		core.onScope { [weak self] in
			self?.rootView = $0.map(ContentView.init)
			self?.scope($0)
		}
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
#endif
