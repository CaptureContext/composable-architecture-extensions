//import CocoaExtensions
//import CocoaAliases
//
//#if os(iOS)
//extension CocoaViewController {
//  public class BindPresentation<Base: CocoaViewController>:
//    NSObject,
//    UIAdaptivePresentationControllerDelegate
//  {
//    weak var base: Base?
//    let dismissSubject = PassthroughSubject<Void, Never>()
//    
//    init(_ base: Base) {
//      self.base = base
//    }
//    
//    public func presentationControllerDidDismiss(
//      _ presentationController: UIPresentationController
//    ) { dismissSubject.send() }
//    
//    public func callAsFunction<
//      PresentationPublisher: Publisher,
//      ChildController: CocoaViewController
//    >(
//      _ isPresenting: PresentationPublisher,
//      to path: ReferenceWritableKeyPath<Base, ChildController?>,
//      create: @escaping () -> ChildController = ChildController.init,
//      animatePresent: @escaping () -> Bool = const(true),
//      animateDismiss: @escaping () -> Bool = const(true),
//      onDismiss: (() -> Void)? = nil
//    ) -> Cancellable where
//      PresentationPublisher.Output == Bool,
//      PresentationPublisher.Failure == Never
//    {
//      var cancellables = Set<AnyCancellable>()
//      
//      var dismissCancellable: Cancellable?
//      cancellables.insert(AnyCancellable { dismissCancellable?.cancel() })
//      
//      isPresenting.removeDuplicates()
//        .sinkValues(capture { _self, isPresenting in
//          let controller = (_self.base?[keyPath: path]).or(create())
//          if
//            isPresenting,
//            !controller.isBeingPresented
//          {
//            _self.base?[keyPath: path] = controller
//            _self.base?.present(controller, animated: animatePresent())
//            controller.presentationController?.delegate = _self
//            dismissCancellable = controller
//              .publisher(for: #selector(UIViewController.dismiss))
//              .sinkValues(_self.dismissSubject.send)
//          } else if !isPresenting {
//            controller.dismiss(animated: animateDismiss())
//          }
//        })
//        .store(in: &cancellables)
//      
//      dismissSubject.sinkValues { onDismiss?() }
//        .store(in: &cancellables)
//      
//      return AnyCancellable { [self] in
//        cancellables.removeAll()
//      }
//    }
//  }
//}
//
//public protocol PresentationBindableController: CocoaViewController {}
//extension PresentationBindableController {
//  public var bindPresentation: BindPresentation<Self> {
//    return .init(self)
//  }
//}
//extension CocoaViewController: PresentationBindableController {}
//#endif
