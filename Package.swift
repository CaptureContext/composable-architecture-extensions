// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "composable-architecture-extensions",
  platforms: [
    .iOS(.v13),
    .macOS(.v11),
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
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMinor(from: "0.47.2")
    ),
    .package(
      url: "https://github.com/capturecontext/combine-extensions.git",
      .upToNextMinor(from: "0.0.3")
    ),
    .package(
      url: "https://github.com/capturecontext/combine-cocoa-navigation.git",
      .upToNextMinor(from: "0.1.0")
    ),
    .package(
      url: "https://github.com/capturecontext/swift-cocoa-extensions.git",
      .upToNextMinor(from: "0.1.0")
    ),
    .package(
      url: "https://github.com/capturecontext/swift-foundation-extensions.git",
      .upToNextMinor(from: "0.1.0")
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
        ),
        .product(
          name: "CombineNavigation",
          package: "combine-cocoa-navigation"
        ),
      ]
    ),
    .target(
      name: "ComposableCore",
      dependencies: [
        .target(name: "ComposableExtensionsCore"),
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
