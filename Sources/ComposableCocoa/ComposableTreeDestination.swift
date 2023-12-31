#if canImport(UIKit) && !os(watchOS)
import Combine
import CocoaExtensions
import ComposableArchitecture
import DeclarativeConfiguration
@_spi(Internals) import CombineNavigation

public typealias ComposableViewTreeDestination<View: ComposableView>
= ComposableTreeDestination<ComposableHostingController<View>>

@propertyWrapper
public class ComposableTreeDestination<Controller: ComposableViewControllerProtocol>: TreeDestination<Controller> {
	public typealias State = Controller.State
	public typealias Action = Controller.Action
	public typealias Store = ComposableArchitecture.Store<State, Action>
	public typealias OptionalStateStore = ComposableArchitecture.Store<State?, Action>

	@inlinable
	public override var wrappedValue: Controller? { super.wrappedValue }

	@inlinable
	public override var projectedValue: ComposableTreeDestination<Controller> { super.projectedValue as! Self }

	@usableFromInline
	internal var store: () -> Store? = { nil }

	@usableFromInline
	internal var optionalStateStore: () -> OptionalStateStore? = { nil }

	@usableFromInline
	func syncController(_ controller: Controller?) {
		if let store = store() {
			controller?.setStore(store)
		} else if let store = optionalStateStore() {
			controller?.setStore(store)
		} else {
			controller?.releaseStore()
		}
	}

	@inlinable
	public convenience init(store: @escaping @autoclosure () -> Store?) {
		self.init()
		self.store = store
	}

	@inlinable
	public convenience init(store: @escaping @autoclosure () -> OptionalStateStore?) {
		self.init()
		self.optionalStateStore = store
	}

	override public func configureController(_ controller: Controller) {
		syncController(controller)
	}

	/// Sets a new store
	@inlinable
	public func setStore(_ store: @escaping @autoclosure () -> Store?) {
		self.store = store
		syncController(wrappedValue)
	}

	/// Sets a new store with an optional state
	@inlinable
	public func setStore(
		_ store: @escaping @autoclosure () -> OptionalStateStore?
	) {
		self.optionalStateStore = store
		syncController(wrappedValue)
	}

	@inlinable
	public func releaseStore() {
		wrappedValue?.releaseStore()
	}

	@_spi(Internals)
	override public func _invalidateDestination() {
		self.releaseStore()
		super._invalidateDestination()
	}
}
#endif
