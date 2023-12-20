#if canImport(UIKit) && !os(watchOS)
import Combine
import CocoaExtensions
import ComposableArchitecture
import DeclarativeConfiguration
@_spi(Internals) import CombineNavigation

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

	@inlinable
	public override var wrappedValue: [DestinationID: Controller] {
		super.wrappedValue
	}

	@inlinable
	public override var projectedValue: ComposableStackDestination<Controller> {
		super.projectedValue as! Self
	}

	@usableFromInline
	internal var cores: [DestinationID: ComposableCore<State, Action>] = [:]

	@usableFromInline
	internal func core(for id: DestinationID) -> ComposableCore<State, Action> {
		return cores[id] ?? {
			let core = ComposableCore<State, Action>()
			core.onStoreDidSet { [weak self] in self?.storeDidSet(for: id, from: $0, to: $1) }
			self.cores[id] = core
			return core
		}()
	}

	override public func configureController(
		_ controller: Controller,
		for id: DestinationID
	) {
		controller.setStore(core(for: id).store)
	}

	/// Sets a new store with an optional state
	@inlinable
	public func setStore(
		_ store: ComposableArchitecture.Store<State?, Action>?,
		for id: DestinationID
	) {
		core(for: id).setStore(store)
	}

	/// Sets a new store
	@inlinable
	public func setStore(_ store: Store?, for id: DestinationID) {
		core(for: id).setStore(store)
	}

	@inlinable
	public func releaseStore(for id: DestinationID) {
		cores.removeValue(forKey: id)?.releaseStore()
		wrappedValue[id]?.releaseStore()
	}

	@_spi(Internals)
	override public func _invalidateDestination(for id: DestinationID) {
		self.releaseStore(for: id)
		super._invalidateDestination(for: id)
	}

	@usableFromInline
	internal func storeDidSet(
		for id: DestinationID,
		from oldStore: Store?,
		to newStore: Store?
	) {
		wrappedValue[id]?.setStore(core(for: id).store)
	}
}
#endif
