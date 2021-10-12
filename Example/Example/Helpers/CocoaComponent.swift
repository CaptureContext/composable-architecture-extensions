#if canImport(SwiftUI)
import SwiftUI
import CocoaAliases

public struct CocoaComponent<Representable: View>: View {
  internal let content: () -> Representable
  public var body: some View { content() }
}

public struct _CocoaViewRepresentable<Content: CocoaView, Coordinator>: CocoaViewRepresentable {
  internal let content: (Context) -> Content
  internal let update: (Content, Context) -> Void
  internal let coordinator: () -> Coordinator
  
  public func makeCocoaView(context: Context) -> Content {
    content(context)
  }
  
  public func updateCocoaView(_ content: Content, context: Context) {
    update(content, context)
  }
  
  public func makeCoordinator() -> Coordinator {
    coordinator()
  }
}

public struct _CocoaViewControllerRepresentable<Content: CocoaViewController, Coordinator>: CocoaViewControllerRepresentable {
  internal let content: (Context) -> Content
  internal let update: (Content, Context) -> Void
  internal let coordinator: () -> Coordinator
  
  public func makeCocoaViewController(context: Context) -> Content {
    content(context)
  }
  
  public func updateCocoaViewController(_ content: Content, context: Context) {
    update(content, context)
  }
  
  public func makeCoordinator() -> Coordinator {
    coordinator()
  }
}

extension CocoaComponent {
  public init<
    Content: CocoaView,
    Coordinator
  >(
    content: @escaping (Representable.Context) -> Content,
    update: @escaping (Content, Representable.Context) -> Void,
    coordinator: @escaping () -> Coordinator
  ) where Representable == _CocoaViewRepresentable<Content, Coordinator> {
    self.init(content: {
      Representable(
        content: content,
        update: update,
        coordinator: coordinator
      )
    })
  }
  
  public init<
    Content: CocoaView,
    Coordinator
  >(
    _ content: @escaping @autoclosure () -> Content,
    update: @escaping (Content, Representable.Context) -> Void,
    coordinator: @escaping () -> Coordinator
  ) where Representable == _CocoaViewRepresentable<Content, Coordinator> {
    self.init(content: {
      Representable(
        content: { _ in content() },
        update: update,
        coordinator: coordinator
      )
    })
  }
  
  public init<Content: CocoaView>(
    content: @escaping (Representable.Context) -> Content,
    update: @escaping (Content, Representable.Context) -> Void = { _, _ in }
  ) where Representable == _CocoaViewRepresentable<Content, Void> {
    self.init(content: {
      Representable(
        content: content,
        update: update,
        coordinator: {}
      )
    })
  }
  
  public init<Content: CocoaView>(
    _ content: @escaping @autoclosure () -> Content,
    update: @escaping (Content, Representable.Context) -> Void = { _, _ in }
  ) where Representable == _CocoaViewRepresentable<Content, Void> {
    self.init(content: {
      Representable(
        content: { _ in content() },
        update: update,
        coordinator: {}
      )
    })
  }
}
  
extension CocoaComponent {
  public init<
    Content: CocoaViewController,
    Coordinator
  >(
    content: @escaping (Representable.Context) -> Content,
    update: @escaping (Content, Representable.Context) -> Void,
    coordinator: @escaping () -> Coordinator
  ) where Representable == _CocoaViewControllerRepresentable<Content, Coordinator> {
    self.init(content: {
      Representable(
        content: content,
        update: update,
        coordinator: coordinator
      )
    })
  }
  
  public init<
    Content: CocoaViewController,
    Coordinator
  >(
    _ content: @escaping @autoclosure () -> Content,
    update: @escaping (Content, Representable.Context) -> Void,
    coordinator: @escaping () -> Coordinator
  ) where Representable == _CocoaViewControllerRepresentable<Content, Coordinator> {
    self.init(content: {
      Representable(
        content: { _ in content() },
        update: update,
        coordinator: coordinator
      )
    })
  }
  
  public init<Content: CocoaViewController>(
    content: @escaping (Representable.Context) -> Content,
    update: @escaping (Content, Representable.Context) -> Void = { _, _ in }
  ) where Representable == _CocoaViewControllerRepresentable<Content, Void> {
    self.init(content: {
      Representable(
        content: content,
        update: update,
        coordinator: {}
      )
    })
  }
  
  public init<Content: CocoaViewController>(
    _ content: @escaping @autoclosure () -> Content,
    update: @escaping (Content, Representable.Context) -> Void = { _, _ in }
  ) where Representable == _CocoaViewControllerRepresentable<Content, Void> {
    self.init(content: {
      Representable(
        content: { _ in content() },
        update: update,
        coordinator: {}
      )
    })
  }
}

#endif
