import Foundation

@_spi(Internals)
public enum ComposableCoreSetStoreMode {
	/// Default mode, instantly updates the store and calls delegate methods
	case update

	/// Core will retain store as a cached instance for later use
	/// but won't call any delegate methods
	case cache
}

@_spi(Internals)
public protocol ComposableCoreDelegate<State, Action>: AnyObject, ComposableObjectProtocol {
	/// Specifies the behavior of `ComposableCore.setStore` method
	var setStoreMode: ComposableCoreSetStoreMode { get }

	/// Composite composable objects can use this handle to
	/// bind store to child stores
	///
	/// This method is called right after `storeDidSet`, right before the `bind` method
	///
	/// - Parameters:
	///   - store: Updated store from the core
	func scope(
		_ store: Store?
	)

	/// Composable objects can use this handle to perform cleanup
	/// when newStore is nil
	///
	/// This method is called right before setting new store to the core
	///
	/// - Parameters:
	///   - oldStore: Current store in the core
	///   - newStore: Store that will be set right after this method returns
	func storeWillSet(
		from oldStore: Store?,
		to newStore: Store?
	)


	/// Composable objects can use this handle to perform cleanup
	/// when newStore is nil
	///
	/// This method is called right after setting new store to the core
	///
	/// - Parameters:
	///   - oldStore: Old store, removed from the core
	///   - newStore: Current store in the core
	func storeDidSet(
		from oldStore: Store?,
		to newStore: Store?
	)

	/// Composable objects can use this method
	/// to bind stores
	///
	/// - Parameters:
	///   - store: Current store in the core
	///   - cancellables: Cancellables
	func bind(
		_ store: Store,
		into cancellables: ComposableCoreCancellables
	)
}

extension ComposableCoreDelegate {
	public var setStoreMode: ComposableCoreSetStoreMode { .update }
}
