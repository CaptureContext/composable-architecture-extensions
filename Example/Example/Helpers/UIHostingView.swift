import SwiftUI
import UIKit
import CocoaExtensions

class UIHostingView<RootView: View>: CustomCocoaView {
  let controller: UIHostingController<RootView>
  
  public convenience init(@ViewBuilder content: () -> RootView) {
    self.init(rootView: content())
  }
  
  public init(rootView: RootView) {
    self.controller = .init(rootView: rootView)
    super.init(frame: .zero)
  }
  
  override init(frame: CGRect) {
    guard let rootView = Self.tryInitOptionalRootView()
    else { fatalError("Root view is not expressible by nil literal") }
    self.controller = UIHostingController(rootView: rootView)
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    guard let rootView = Self.tryInitOptionalRootView()
    else { fatalError("Root view is not expressible by nil literal") }
    self.controller = UIHostingController(rootView: rootView)
    super.init(coder: coder)
  }
  
  var rootView: RootView {
    get { controller.rootView }
    set { controller.rootView = newValue }
  }
  
  override func _commonInit() {
    super._commonInit()
    self.backgroundColor = .clear
    self.controller.view.backgroundColor = .clear
    self.addSubview(controller.view)
  }
  
  override func layoutSubviews() {
    controller.view.frame = bounds
    controller.view.setNeedsLayout()
  }
}

extension UIHostingView {
  fileprivate static func tryInitOptionalRootView() -> RootView? {
    guard
      let rootViewType = RootView.self as? ExpressibleByNilLiteral.Type,
      let rootView = rootViewType.init(nilLiteral: ()) as? RootView
    else { return nil }
    return rootView
  }
}
