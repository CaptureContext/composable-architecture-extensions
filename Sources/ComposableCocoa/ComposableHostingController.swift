#if !os(watchOS)
import SwiftUI
import CocoaAliases
import Combine
import CocoaExtensions
import ComposableArchitecture

#if canImport(UIKit)
import CombineNavigation
extension ComposableHostingController: DestinationInitializableControllerProtocol {}
#endif

public protocol ComposableHostingControllerProtocol<ContentView>:
	CustomHostingController<Self.ContentView?>,
	ComposableViewControllerProtocol
where State == ContentView.State, Action == ContentView.Action {
	associatedtype ContentView: ComposableView
}

public class ComposableHostingController<ContentView: ComposableView>:
	CustomHostingController<ContentView?>,
	ComposableHostingControllerProtocol
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
		self.init()
		core.setStore(store)
	}

	@inlinable
	public convenience init(store: ComposableArchitecture.Store<State?, Action>?) {
		self.init()
		core.setStore(store)
	}

	@_implements(DestinationInitializableControllerProtocol, init())
	@inlinable
	public required init() {
		super.init(rootView: ContentView?.none)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	public override init(rootView: ContentView?) {
		super.init(rootView: rootView)
	}

	public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(rootView: nil)
	}

	public override init?(coder: NSCoder, rootView: ContentView?) {
		super.init(coder: coder, rootView: rootView)
	}
	
	public override func _init() {
		super._init()
		core.onScope { [weak self] in
			self?.rootView = $0.map(ContentView.init)
		}
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
}
#endif
