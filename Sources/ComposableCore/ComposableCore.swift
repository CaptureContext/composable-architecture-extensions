//
//  ComposableCore.swift
//  Xgen
//
//  Created by Maxim Krouk on 07.05.2021.
//  Copyright © 2021 MakeupStudio. All rights reserved.
//

import CombineExtensions
import ComposableArchitecture
import FoundationExtensions

#if canImport(SwiftUI)
import SwiftUI
#endif

public final class ComposableCore<State, Action>: ComposableCoreProtocol {
  
  // MARK: - Aliases
  
  public typealias Store = ComposableArchitecture.Store<State, Action>
  public typealias ViewStore = ComposableArchitecture.ViewStore<State, Action>
  public typealias StorePublisher = ComposableArchitecture.StorePublisher<State>
  public typealias Cancellables = Set<AnyCancellable>

  // MARK: - Properties
  @usableFromInline
  var _store: Store?

  @usableFromInline
  var _viewStore: ViewStore?

  @inlinable
  public var store: Store? { _store }

  @inlinable
  public var viewStore: ViewStore? { _viewStore }

  public var state: State? { viewStore?.state }
  
  /// Cancellable for optional state stores
  @usableFromInline
  var storeCancellables: Cancellables = []
  
  /// Cancellables for binded state
  @usableFromInline
  var stateCancellables: Cancellables = []
  
  /// You can store any cancellables here
  ///
  /// It's a convenient helper and not used by the Core internally
  public var cancellablesStorage: [AnyHashable: Cancellable] = [:]

  @usableFromInline
  let lock = NSLock()
  
  // MARK: - Stored Handlers

  @usableFromInline
  var _bind: ((StorePublisher, inout Cancellables) -> Void)?

  @usableFromInline
  var _scope: ((Store?) -> Void)?

  @usableFromInline
  var _storeWillSet: ((Store?, Store?) -> Void)?

  @usableFromInline
  var _storeDidSet: ((Store?, Store?) -> Void)?

  @inlinable
  public init() {}



  /// Handler for state rebinding on the `setStore` method call
  ///
  /// NOTE: ComposableObjectProtocol relies on that property
  @inlinable
  public func onBind(perform action: ((StorePublisher, inout Cancellables) -> Void)?) {
    self._bind = action
  }
  
  /// Handler for scoping the store to derived stores on the `setStore` method call
  ///
  /// NOTE: ComposableObjectProtocol relies on that property
  @inlinable
  public func onScope(perform action: ((Store?) -> Void)?) {
    self._scope = action
  }
  
  /// Handler for the `setStore` method
  ///
  /// NOTE: ComposableObjectProtocol relies on that property
  @inlinable
  public func onStoreWillSet(perform action: ((Store?, Store?) -> Void)?) {
    self._storeWillSet = action
  }
  
  /// Handler for the `setStore` method completion
  ///
  /// NOTE: ComposableObjectProtocol relies on that property
  @inlinable
  public func onStoreDidSet(perform action: ((Store?, Store?) -> Void)?) {
    self._storeDidSet = action
  }
  
  // MARK: - Set store

  /// Sets a new store with an optional state
  @inlinable
  public func setStore(
    _ store: ComposableArchitecture.Store<State?, Action>?
  ) where State: Equatable {
    self.setStore(store, removeDuplicates: ==)
  }

  /// Sets a new store with an optional state
  @inlinable
  public func setStore(
    _ store: ComposableArchitecture.Store<State?, Action>?,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    guard let store = store else { return releaseStore() }

    storeCancellables.removeAll()
    store._ifLet(
      then: { [weak self] store in
        self?.setStore(store, removeDuplicates: isDuplicate)
      },
      else: { [weak self] in
        self?.releaseStore()
      }
    ).store(in: &storeCancellables)
  }

  /// Sets a new store
  @inlinable
  public func setStore(
    _ store: ComposableArchitecture.Store<State, Action>?
  ) where State: Equatable {
    self.setStore(store, removeDuplicates: ==)
  }

  /// Sets a new store
  @inlinable
  public func setStore(
    _ store: Store?,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    storeCancellables.removeAll()
    let oldStore = self.store
    self._storeWillSet?(oldStore, store)
    self._store = store
    self._viewStore = store.map { store in
      ViewStore(store, removeDuplicates: isDuplicate)
    }

    self._scope?(store)
    self.subscribeToStateChanges()
    self._storeDidSet?(oldStore, store)
  }

  @inlinable
  public func releaseStore() {
    setStore(Store?.none, removeDuplicates: { _, _ in false })
  }

  @inlinable
  public func subscribeToStateChanges() {
    lock.lock()
    stateCancellables.removeAll()
    if let statePublishser = viewStore?.publisher {
      _bind?(statePublishser, &stateCancellables)
    }
    lock.unlock()
  }
  
  // MARK: - Send

  @discardableResult
  @inlinable
  public func send(_ action: Action) -> ViewStoreTask? {
    guard let viewStore = viewStore else { return nil }
    return viewStore.send(action)
  }

  #if canImport(SwiftUI)
  @discardableResult
  @inlinable
  public func send(
    _ action: Action,
    animation: Animation?
  ) -> ViewStoreTask? {
    guard let viewStore else { return nil }
    return viewStore.send(action, animation: animation)
  }
  #endif
}

extension ComposableCore {
  /// Sets a new store only if the old one was nil or parents are different
  @inlinable
  public func setStoreIfNeeded(
    _ store: ComposableArchitecture.Store<State?, Action>
  ) where State: Equatable {
    self.setStoreIfNeeded(store, removeDuplicates: ==)
  }
  
  /// Sets a new store only if the old one was nil or parents are different
  @inlinable
  public func setStoreIfNeeded(
    _ store: ComposableArchitecture.Store<State?, Action>,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    storeCancellables.removeAll()
    store._ifLet(
      then: { [weak self] store in
        self?.setStoreIfNeeded(store, removeDuplicates: isDuplicate)
      },
      else: { [weak self] in
        self?.releaseStore()
      }
    ).store(in: &storeCancellables)
  }
  
  /// Sets a new store only if the old one was nil or parents are different
  @inlinable
  public func setStoreIfNeeded(
    _ store: ComposableArchitecture.Store<State, Action>
  ) where State: Equatable {
    self.setStoreIfNeeded(store, removeDuplicates: ==)
  }

  /// Sets a new store only if the old one was nil or parents are different
  @inlinable
  public func setStoreIfNeeded(
    _ store: Store,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    guard self.store.isNil || (self.store?.parentStoreID != store.parentStoreID)
    else { return }
    self.setStore(store, removeDuplicates: isDuplicate)
  }
}

extension Store: AssociatingObject {
  /// `.scope` implementation that tracks store's parent
  @inlinable
  public func _scope<LocalState, LocalAction>(
    state: @escaping (State) -> LocalState,
    action: @escaping (LocalAction) -> Action
  ) -> Store<LocalState, LocalAction> {
    let store = self.scope(state: state, action: action)
    store.parentStoreID = ObjectIdentifier(self)
    return store
  }
  
  /// `.ifLet` implementation that tracks store's parent
  @inlinable
  public func _ifLet<Wrapped>(
    then unwrap: @escaping (Store<Wrapped, Action>) -> Void,
    else: @escaping () -> Void = {}
  ) -> Cancellable where State == Wrapped? {
    let parentStoreID = self.parentStoreID
    return ifLet(
      then: { store in
        store.parentStoreID = parentStoreID
        unwrap(store)
      },
      else: `else`
    )
  }

  @inlinable
  public var parentStoreID: ObjectIdentifier? {
    get { getAssociatedObject(forKey: "parent_store_id") }
    set { setAssociatedObject(newValue, forKey: "parent_store_id") }
  }
}
