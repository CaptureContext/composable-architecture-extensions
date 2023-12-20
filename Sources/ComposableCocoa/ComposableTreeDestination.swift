#if canImport(UIKit) && !os(watchOS)
import Combine
import CocoaExtensions
import ComposableArchitecture
import DeclarativeConfiguration
@_spi(Internals) import CombineNavigation

@propertyWrapper
public class ComposableTreeDestination<Controller: ComposableViewControllerProtocol>: TreeDestination<Controller> {
	public typealias State = Controller.State
	public typealias Action = Controller.Action
	public typealias Store = ComposableArchitecture.Store<State, Action>

	@inlinable
	public override var wrappedValue: Controller? { super.wrappedValue }

	@inlinable
	public override var projectedValue: ComposableTreeDestination<Controller> { super.projectedValue as! Self }

	@usableFromInline
	internal let core: ComposableCore<State, Action> = .init()

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

	public override init() {
		super.init()
		core.onStoreDidSet { [weak self] in self?.storeDidSet(from: $0, to: $1) }
	}

	override public func configureController(_ controller: Controller) {
		controller.setStore(core.store)
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
		wrappedValue?.releaseStore()
	}

	@_spi(Internals)
	override public func _invalidateDestination() {
		self.releaseStore()
		super._invalidateDestination()
	}

	@usableFromInline
	internal func storeDidSet(
		from oldStore: Store?,
		to newStore: Store?
	) {
		wrappedValue?.setStore(newStore)
	}
}
#endif
