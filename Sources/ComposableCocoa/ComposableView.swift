#if canImport(SwiftUI)
import SwiftUI
import ComposableArchitecture

public typealias ComposableViewOf<R: Reducer> = ComposableView<
	R.State,
	R.Action
>

public protocol ComposableView<State, Action>: View {
	associatedtype State
	associatedtype Action
	init(_ store: Store<State, Action>)
}

extension ComposableView {
	public typealias HostingController = ComposableHostingController<Self>
}
#endif
