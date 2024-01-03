#if canImport(UIKit) && !os(watchOS)
import Combine
import CocoaExtensions
import ComposableArchitecture
import DeclarativeConfiguration
@_spi(Internals) import CombineNavigation

public typealias ComposableViewStackDestination<View: ComposableView>
= ComposableStackDestination<ComposableHostingController<View>>

@propertyWrapper
public class ComposableStackDestination<
	Controller: ComposableViewControllerProtocol
>: StackDestination<
	StackElementID,
	Controller
> {
	public typealias State = Controller.State
	public typealias Action = Controller.Action
	public typealias Store = ComposableArchitecture.Store<State, Action>
	public typealias OptionalStateStore = ComposableArchitecture.Store<State?, Action>

	@inlinable
	public override var wrappedValue: [DestinationID: Controller] {
		super.wrappedValue
	}

	@inlinable
	public override var projectedValue: ComposableStackDestination<Controller> {
		super.projectedValue as! Self
	}

	@usableFromInline
	internal var storeForID: (DestinationID) -> Store? = { _ in nil }

	@usableFromInline
	internal var optionalStateStoreForID: (DestinationID) -> OptionalStateStore? = { _ in nil }

	@usableFromInline
	func syncControllers() {
		_controllers.forEach { id, controller in
			syncController(controller, withStoreFor: id)
		}
	}

	@usableFromInline
	func syncController(_ controller: Controller, withStoreFor id: DestinationID) {
		if let store = storeForID(id) {
			controller.setStore(store)
		} else if let store = optionalStateStoreForID(id) {
			controller.setStore(store)
		} else {
			controller.releaseStore()
		}
	}

	@inlinable
	override public func configureController(
		_ controller: Controller,
		for id: DestinationID
	) {
		syncController(controller, withStoreFor: id)
	}

	/// Sets a new store
	@inlinable
	public func setStore(
		_ storeForID: @escaping (DestinationID) -> Store?
	) {
		self.storeForID = storeForID
		self.syncControllers()
	}

	/// Sets a new store with an optional state
	@inlinable
	public func setStore(
		_ optionalStateStoreForID: @escaping (DestinationID) -> OptionalStateStore?
	) {
		self.optionalStateStoreForID = optionalStateStoreForID
		self.syncControllers()
	}

	@inlinable
	public func releaseStore(for id: DestinationID) {
		wrappedValue[id]?.releaseStore()
	}

	@_spi(Internals)
	override public func _invalidate(_ id: DestinationID) {
		self.releaseStore(for: id)
		super._invalidate(id)
	}
}
#endif
