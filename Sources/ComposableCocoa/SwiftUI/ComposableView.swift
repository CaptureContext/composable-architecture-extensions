#if canImport(SwiftUI)
import SwiftUI
import ComposableArchitecture
import CocoaAliases

public typealias ComposableViewOf<R: Reducer> = ComposableView<
	R.State,
	R.Action
>

public protocol ComposableView<State, Action>: View {
	associatedtype State
	associatedtype Action
	init(_ store: Store<State, Action>)
}

extension Optional where Wrapped: ComposableView {
	public init(_ store: Store<Wrapped.State, Wrapped.Action>?) {
		self = store.map(Wrapped.init)
	}
}

extension ComposableView {
	public typealias HostingController = ComposableHostingController<Self>
}
#endif
