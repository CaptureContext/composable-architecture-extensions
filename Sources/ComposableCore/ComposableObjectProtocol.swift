import ComposableArchitecture
import Combine

public typealias ComposableObjectProtocolOf<
	Reducer: ComposableArchitecture.Reducer
> = ComposableObjectProtocol<Reducer.State, Reducer.Action>

public protocol ComposableObjectProtocol<State, Action> {
	associatedtype State
	associatedtype Action

	typealias Store = ComposableArchitecture.Store<State, Action>
	typealias StorePublisher = ComposableArchitecture.StorePublisher<State>
	typealias Cancellables = Set<AnyCancellable>

	var store: Store? { get }

	func setStore(_ store: ComposableArchitecture.Store<State?, Action>?)
	func setStore(_ store: Store?)
	func releaseStore()
}
