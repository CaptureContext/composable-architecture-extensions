import ComposableDependencies

private enum GlobalSchedulersKey: DependencyKey {
  public static var defaultValue: GlobalSchedulersClient { .live }
}

extension Dependencies {
  public var globalSchedulers: GlobalSchedulersClient {
    get { self[GlobalSchedulersKey.self] }
    set { self[GlobalSchedulersKey.self] = newValue }
  }
}
