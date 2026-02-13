import Foundation
import Combine
import SwiftNavigation

public class ComposableCoreCancellables: @unchecked Sendable {
	private let lock: NSLocking = NSRecursiveLock()
	var store: (any Cancellable)?
	var storage: [AnyHashable: (any Cancellable)] = [:]

	func _withLock<T>(perform operation: (ComposableCoreCancellables) -> T) -> T {
		lock.withLock { operation(self) }
	}

	public func removeAll() {
		_withLock {
			let cancellables = $0.storage.values
			cancellables.forEach { $0.cancel() }
			$0.storage.removeAll()
		}
	}
}

extension Cancellable where Self: Hashable {
	/// Stores cancellable in CoreCancellables
	///
	/// - Note: Thread-safe
	@available(
		*, deprecated,
		message: """
		Use `store(in:)` with non-inout ComposableCoreCancellables instead.
		"""
	)
	public func store(
		in coreCancellables: inout ComposableCoreCancellables
	) {
		store(in: coreCancellables)
	}

	/// Stores cancellable in CoreCancellables
	///
	/// - Note: Thread-safe
	public func store(
		in coreCancellables: ComposableCoreCancellables
	) {
		store(in: coreCancellables, forKey: self)
	}
}

extension Cancellable {
	/// Stores cancellable in CoreCancellables
	///
	/// - Note: Thread-safe
	public func store(
		in coreCancellables: ComposableCoreCancellables,
		forKey key: AnyHashable
	) {
		coreCancellables._withLock { $0.storage[key] = self }
	}
}

extension ObserveToken: @retroactive Cancellable {}
