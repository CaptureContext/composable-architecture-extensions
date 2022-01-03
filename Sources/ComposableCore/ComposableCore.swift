//
//  ComposableCore.swift
//  Xgen
//
//  Created by Maxim Krouk on 07.05.2021.
//  Copyright © 2021 MakeupStudio. All rights reserved.
//

import CombineExtensions
import ComposableArchitecture
import StoreSchedulers

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
  
  public var state: State? { viewStore?.state }
  private(set) public var store: Store?
  private(set) public var viewStore: ViewStore?
  
  /// Cancellable for optional state stores
  private var storeCancellables: Cancellables = []
  
  /// Cancellables for binded state
  private var stateCancellables: Cancellables = []
  
  /// You can store any cancellables here
  public var cancellablesStorage: [AnyHashable: Cancellable] = [:]
  
  private let lock = NSLock()
  
  // MARK: - Handlers

  private var _bind: ((StorePublisher, inout Cancellables) -> Void)?

  /// Handler for state rebinding on the `setStore` method call
  public func onBind(perform action: ((StorePublisher, inout Cancellables) -> Void)?) {
    self._bind = action
  }

  private var _scope: ((Store?) -> Void)?
  
  /// Handler for scoping the store to derived stores on the `setStore` method call
  public func onScope(perform action: ((Store?) -> Void)?) {
    self._scope = action
  }

  private var _storeWillSet: ((Store?, Store?) -> Void)?
  
  /// Handler for the `setStore` method
  public func onStoreWillSet(perform action: ((Store?, Store?) -> Void)?) {
    self._storeWillSet = action
  }

  /// Handler for the `setStore` method completion
  public var _storeDidSet: ((Store?, Store?) -> Void)?
  
  public func onStoreDidSet(perform action: ((Store?, Store?) -> Void)?) {
    self._storeDidSet = action
  }

  public init() {}
  
  // MARK: - Set store

  public func setStore(
    _ store: ComposableArchitecture.Store<State?, Action>?
  ) where State: Equatable {
    self.setStore(store, removeDuplicates: ==)
  }

  public func setStore(
    _ store: ComposableArchitecture.Store<State?, Action>?,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    guard let store = store else { return releaseStore() }

    storeCancellables.removeAll()
    store.ifLet(
      then: { [weak self] store in
        self?.setStore(store, removeDuplicates: isDuplicate)
      },
      else: { [weak self] in
        self?.releaseStore()
      }
    ).store(in: &storeCancellables)
  }

  public func setStore(
    _ store: ComposableArchitecture.Store<State, Action>?
  ) where State: Equatable {
    self.setStore(store, removeDuplicates: ==)
  }

  public func setStore(
    _ store: Store?,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    storeCancellables.removeAll()
    let oldStore = self.store
    self._storeWillSet?(oldStore, store)
    self.store = store
    self.viewStore = store.map { store in
      ViewStore(store, removeDuplicates: isDuplicate)
    }

    self._scope?(store)
    self.subscribeToStateChanges()
    self._storeDidSet?(oldStore, store)
  }

  public func releaseStore() {
    setStore(Store?.none, removeDuplicates: { _, _ in false })
  }

  public func subscribeToStateChanges() {
    lock.lock()
    stateCancellables.removeAll()
    if let statePublishser = viewStore?.publisher {
      _bind?(statePublishser, &stateCancellables)
    }
    lock.unlock()
  }
  
  // MARK: - Send

  public func send(_ action: Action) {
    guard let viewStore = viewStore else { return }
    viewStore.send(action)
  }

  public func sendAsync(
    _ action: Action,
    on scheduler: NoOptionsSchedulerOf<DispatchQueue> = .eventHandling
  ) {
    scheduler.schedule { [weak self] in
      self?.send(action)
    }
  }

  #if canImport(SwiftUI)
    public func send(_ action: Action, animation: Animation?) {
      viewStore.map { $0.send(action, animation: animation) }
    }
  #endif
}

extension ComposableCore {
  public func setStoreIfNeeded(
    _ store: ComposableArchitecture.Store<State?, Action>
  ) where State: Equatable {
    self.setStoreIfNeeded(store, removeDuplicates: ==)
  }
  
  public func setStoreIfNeeded(
    _ store: ComposableArchitecture.Store<State?, Action>,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    storeCancellables.removeAll()
    let sid: ObjectIdentifier? = store.getAssociatedObject(forKey: "parent_store")
    store.ifLet(
      then: { [weak self] store in
        store.setAssociatedObject(sid, forKey: "parent_store")
        self?.setStoreIfNeeded(store, removeDuplicates: isDuplicate)
      },
      else: { [weak self] in
        self?.releaseStore()
      }
    ).store(in: &storeCancellables)
  }
  
  public func setStoreIfNeeded(
    _ store: ComposableArchitecture.Store<State, Action>
  ) where State: Equatable {
    self.setStoreIfNeeded(store, removeDuplicates: ==)
  }

  public func setStoreIfNeeded(
    _ store: Store,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    func isSameParent() -> Bool {
      let oldID: ObjectIdentifier? = self.store?.getAssociatedObject(forKey: "parent_store")
      let newID: ObjectIdentifier? = store.getAssociatedObject(forKey: "parent_store")
      return oldID == newID
    }
    if self.store.isNil || !isSameParent() {
      self.setStore(store, removeDuplicates: isDuplicate)
    }
  }
}

protocol AssociationProvider {}

extension Store: AssociationProvider {
  public func _scope<LocalState, LocalAction>(
    state: @escaping (State) -> LocalState,
    action: @escaping (LocalAction) -> Action
  ) -> Store<LocalState, LocalAction> {
    let store = self.scope(state: state, action: action)
    store.setParent(self)
    return store
  }
  
  public func setParent<GlobalState, GlobalAction>(
    _ store: Store<GlobalState, GlobalAction>
  ) {
    setAssociatedObject(ObjectIdentifier(store), forKey: "parent_store")
  }
}

extension AssociationProvider {
  @inlinable
  @discardableResult
  public func setAssociatedObject<Object>(
    _ object: Object,
    forKey key: StaticString,
    policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
  ) -> Bool {
    key.withUTF8Buffer { pointer in
      if let p = pointer.baseAddress.map(UnsafeRawPointer.init) {
        objc_setAssociatedObject(self, p, object, policy)
        return true
      } else {
        return false
      }
    }
  }
  
  @inlinable
  public func getAssociatedObject<Object>(
    of type: Object.Type = Object.self,
    forKey key: StaticString
  ) -> Object? {
    key.withUTF8Buffer { pointer in
      if let p = pointer.baseAddress.map(UnsafeRawPointer.init) {
        return objc_getAssociatedObject(self, p) as? Object
      } else {
        return nil
      }
    }
  }
}
