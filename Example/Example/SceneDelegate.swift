//
//  SceneDelegate.swift
//  Example
//
//  Created by Maxim Krouk on 5.10.21.
//

import UIKit
import SwiftUI
import ComposableExtensions
import Combine
import FlowStacks
import CocoaExtensions

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    let contentView = MainView(
      Store(
        initialState: MainState(counters: CountersState(counters: [.init()])),
        reducer: mainReducer.debug(),
        environment: MainEnvironment()
      )
    )
    
    // Use a UIHostingController as window root view controller.
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
//      window.rootViewController = UIHostingController(rootView: contentView)
      window.rootViewController = UserProfileViewController()
      self.window = window
      window.makeKeyAndVisible()
    }
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {}
  
  func sceneDidBecomeActive(_ scene: UIScene) {}
  
  func sceneWillResignActive(_ scene: UIScene) {}
  
  func sceneWillEnterForeground(_ scene: UIScene) {}
  
  func sceneDidEnterBackground(_ scene: UIScene) {}
}

extension UICollectionViewLayout {
  static func compositional(_ layout: UICollectionViewCompositionalLayout) -> UICollectionViewLayout {
    layout
  }
}

extension UICollectionViewCompositionalLayout {
  public static func profile()
  -> UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { section, environment in
      if section == 0 {
        return NSCollectionLayoutSection(
          group: NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1),
              heightDimension: .estimated(100)
            ),
            subitems: [
              NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1),
                  heightDimension: .fractionalHeight(1)
                )
              )
            ]
          )
        )
      } else if section == 1 {
        func makeItem() -> NSCollectionLayoutItem {
          NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(0.5),
              heightDimension: .fractionalHeight(1)
            )
          )
        }
        
        return NSCollectionLayoutSection(
          group: NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(2),
              heightDimension: .absolute(environment.container.contentSize.height)
            ),
            subitems: [
              makeItem(),
              makeItem(),
              makeItem()
            ]
          )
        ).configured { $0
          .orthogonalScrollingBehavior(.paging)
        }
      } else {
        fatalError("Profile layout does not support numberOfSections > 2")
      }
    }
  }
  
  public static func profileThreadItems()
  -> UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { section, environment in
      func makeItem() -> NSCollectionLayoutItem {
        NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .absolute((environment.container.effectiveContentSize.width - 24) / 3),
            heightDimension: .fractionalHeight(1)
          )
        )
      }
      
      func makeGroup() -> NSCollectionLayoutGroup {
        NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1/4)
          ),
          subitems: [
            makeItem(),
            makeItem(),
            makeItem()
          ]
        ).configured { $0
          .interItemSpacing(.fixed(12))
        }
      }
      
      func makeSection() -> NSCollectionLayoutSection {
        NSCollectionLayoutSection(
          group: makeGroup()
        ).configured { $0
          .interGroupSpacing(12)
        }
      }
      
      return makeSection()
    }
  }
}

public class UserProfileViewController: CustomCocoaViewController {
  @CustomView
  var contentView: ContentView
  
  var questionsController = UserProfileThreadItemsViewController()
  var answersController = UserProfileThreadItemsViewController()
  var bookmarksController = UserProfileThreadItemsViewController()
  let pageController = UIPageViewController(
    transitionStyle: .scroll,
    navigationOrientation: .horizontal,
    options: nil
  )
  
  public override func viewDidLoad() {
    super.viewDidLoad()
//    contentView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "id")
//    contentView.collectionView.dataSource = self
    contentView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "id")
    contentView.tableView.delegate = self
    contentView.tableView.dataSource = self
    pageController.setViewControllers([questionsController], direction: .forward, animated: false, completion: nil)
  }
}

extension UserProfileViewController {
  final class ContentView: CustomCocoaView {
    var collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: .compositional(.profile())
    )
    
    var tableView = UITableView(frame: .zero, style: .plain)
    
    override func _init() {
      addSubview(tableView)
    }
    
    override func layoutSubviews() {
      tableView.frame = bounds
      tableView.subviews.forEach { $0.setNeedsLayout() }
    }
  }
}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  public func presentationCount(for pageViewController: UIPageViewController) -> Int {
    3
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if viewController === questionsController {
      return answersController
    } else if viewController === answersController {
      return bookmarksController
    } else {
      return nil
    }
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if viewController === bookmarksController {
      return answersController
    } else if viewController === answersController {
      return questionsController
    } else {
      return nil
    }
  }
  public func numberOfSections(in tableView: UITableView) -> Int { 2 }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    match(section) {
      switch $0 {
      case 0: return 1
      case 1: return 1
      default: return 0
      }
    }
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "id").or(UITableViewCell())
    switch indexPath.section {
    case 0:
      cell.backgroundColor = .red
      
    case 1:
      pageController.willMove(toParent: nil)
      cell.contentView.subviews.forEach { $0.removeFromSuperview() }
      pageController.removeFromParent()
      cell.backgroundColor = .yellow
      
      addChild(pageController)
      cell.contentView.addSubview(pageController.view)
      pageController.view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        pageController.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
        pageController.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
        pageController.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
        pageController.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
      ])
      pageController.didMove(toParent: self)
      
    default:
      break
    }
    return cell
  }
  
  public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    section == 1 ? "Hello" : nil
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    section == 1 ? 44 : 0
  }
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 { return 300 }
    if indexPath.section == 1 { return tableView.bounds.height }
    return 0
  }
  
}

extension UserProfileViewController: UICollectionViewDataSource {
  public func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
  
  public func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    match(section) {
      switch $0 {
      case 0: return 1
      case 1: return 3
      default: return 0
      }
    }
  }
  
  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "id",
      for: indexPath
    )
    
    switch indexPath.section {
    case 0:
      if cell.contentView.subviews.isEmpty {
        let label = UILabel { $0
          .backgroundColor(.red)
          .textAlignment(.center)
          .translatesAutoresizingMaskIntoConstraints(false)
        }
        cell.contentView.addSubview(label)
        NSLayoutConstraint.activate([
          label.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
          label.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
          label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
          label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
          label.heightAnchor.constraint(equalToConstant: 300)
        ])
      }
      
      if let label = cell.contentView.subviews.first.as(UILabel.self) {
        label.configure { $0
          .text("\(indexPath.section):\(indexPath.item)")
        }
      }
      
    case 1:
      cell.contentView.subviews.forEach { $0.removeFromSuperview() }
      match(indexPath.item) { (index) -> UIViewController? in
        switch index {
        case 0: return questionsController
        case 1: return answersController
        case 2: return bookmarksController
        default: return nil
        }
      }.map { controller in
        cell.contentView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          controller.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
          controller.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
          controller.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
          controller.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])
        addChild(controller)
        controller.didMove(toParent: self)
      }
      
    default:
      break
    }
    
    return cell
  }
}

public class UserProfileThreadItemsViewController: CustomCocoaViewController {
  @CustomView
  var contentView: ContentView
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    contentView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "id")
    contentView.collectionView.dataSource = self
  }
}

extension UserProfileThreadItemsViewController {
  final class ContentView: CustomCocoaView {
    var collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: .compositional(.profileThreadItems())
    )
    
    override func _init() {
      collectionView.bounces = false
      addSubview(collectionView)
    }
    
    override func layoutSubviews() {
      collectionView.frame = bounds
      collectionView.subviews.forEach { $0.setNeedsLayout() }
    }
  }
}

extension UserProfileThreadItemsViewController: UICollectionViewDataSource {
  public func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
  
  public func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    match(section) {
      switch $0 {
      case 0: return 100
      default: return 0
      }
    }
  }
  
  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "id",
      for: indexPath
    )
    
    if cell.contentView.subviews.isEmpty {
      let label = UILabel { $0
        .textAlignment(.center)
        .translatesAutoresizingMaskIntoConstraints(false)
      }
      cell.contentView.addSubview(label)
      NSLayoutConstraint.activate([
        label.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
        label.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
        label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
        label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
      ])
    }
    
    if let label = cell.contentView.subviews.first.as(UILabel.self) {
      label.configure { $0
        .backgroundColor(indexPath.section == 0 ? .blue : .green)
        .text("\(indexPath.section):\(indexPath.item)")
      }
    }
    
    return cell
  }
}
