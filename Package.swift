// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "composable-architecture-extensions",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [ // MARK: - Products
    .library(
      name: "ComposableCocoa",
      type: .static,
      targets: ["ComposableCocoa"]
    ),
    .library(
      name: "ComposableCore",
      type: .static,
      targets: ["ComposableCore"]
    ),
    .library(
      name: "ComposableExtensions",
      type: .static,
      targets: ["ComposableExtensions"]
    ),
    .library(
      name: "ComposableNavigation",
      type: .static,
      targets: ["ComposableNavigation"]
    ),
    .library(
      name: "StoreSchedulers",
      type: .static,
      targets: ["StoreSchedulers"]
    )
  ],
  dependencies: [
    .package(
      name: "swift-composable-architecture",
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "0.31.0")
    ),
    .package(
      name: "swift-composable-environment",
      url: "https://github.com/tgrapperon/swift-composable-environment.git",
      .upToNextMinor(from: "0.5.1")
    ),
    .package(
      name: "combine-extensions",
      url: "https://github.com/capturecontext/combine-extensions.git",
      .upToNextMinor(from: "0.0.3")
    ),
    .package(
      name: "swift-cocoa-extensions",
      url: "https://github.com/capturecontext/swift-cocoa-extensions.git",
      .branch("main")
    ),
    .package(
      name: "swift-foundation-extensions",
      url: "https://github.com/capturecontext/swift-foundation-extensions.git",
      .branch("main")
    )
  ],
  targets: [ // MARK: - Targets
    .target(
      name: "ComposableCocoa",
      dependencies: [
        .target(name: "ComposableCore"),
        .target(name: "ComposableNavigation"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "CocoaExtensions",
          package: "swift-cocoa-extensions"
        )
      ]
    ),
    .target(
      name: "ComposableCore",
      dependencies: [
        .target(name: "ComposableExtensionsCore"),
        .target(name: "StoreSchedulers"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "CombineExtensions",
          package: "combine-extensions"
        )
      ]
    ),
    .target(
      name: "ComposableExtensions",
      dependencies: [
        .target(name: "ComposableCocoa"),
        .target(name: "ComposableCore"),
        .target(name: "ComposableNavigation")
      ]
    ),
    .target(
      name: "ComposableExtensionsCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "FoundationExtensions",
          package: "swift-foundation-extensions"
        ),
        .product(
          name: "CombineExtensions",
          package: "combine-extensions"
        )
      ]
    ),
    .target(
      name: "ComposableNavigation",
      dependencies: [
        .target(name: "ComposableExtensionsCore"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        )
      ]
    ),
    .target(
      name: "StoreSchedulers",
      dependencies: [
        .product(
          name: "CombineExtensions",
          package: "combine-extensions"
        ),
        .product(
          name: "ComposableDependencies",
          package: "swift-composable-environment"
        )
      ]
    ),
    
    // MARK: - Tests
    .testTarget(
      name: "ComposableCoreTests",
      dependencies: [
        .target(name: "ComposableCore")
      ]
    ),
    .testTarget(
      name: "ComposableExtensionsCoreTests",
      dependencies: [
        .target(name: "ComposableExtensionsCore")
      ]
    ),
    .testTarget(
      name: "ComposableNavigationTests",
      dependencies: [
        .target(name: "ComposableNavigation")
      ]
    ),
  ]
)
