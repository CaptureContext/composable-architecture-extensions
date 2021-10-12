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
  products: [
    .library(
      name: "ComposableCocoa",
      targets: ["ComposableCocoa"]
    ),
    .library(
      name: "ComposableCore",
      targets: ["ComposableCore"]
    ),
    .library(
      name: "ComposableExtensions",
      targets: ["ComposableExtensions"]
    ),
    .library(
      name: "ComposableNavigation",
      targets: ["ComposableNavigation"]
    ),
  ],
  dependencies: [
    .package(
      name: "swift-composable-architecture",
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "0.28.1")
    ),
    .package(
      name: "swift-composable-environment",
      url: "https://github.com/tgrapperon/swift-composable-environment.git",
      .upToNextMinor(from: "0.4.0")
    ),
    .package(
      name: "combine-extensions",
      url: "https://github.com/capturecontext/combine-extensions.git",
      .upToNextMinor(from: "0.0.1")
    ),
    .package(
      name: "swift-standard-extensions",
      url: "https://github.com/edudo-inc/swift-standard-extensions.git",
      .branch("develop")
    )
  ],
  targets: [
    .target(
      name: "ComposableCocoa",
      dependencies: [
        .target(name: "ComposableCore"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "CocoaExtensions",
          package: "swift-standard-extensions"
        )
      ]
    ),
    .target(
      name: "ComposableCore",
      dependencies: [
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
        .target(name: "ComposableNavigation"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "ComposableEnvironment",
          package: "swift-composable-environment"
        )
      ]
    ),
    .target(
      name: "ComposableExtensionsCore",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        )
      ]
    ),
    .target(
      name: "ComposableNavigation",
      dependencies: [
        .target(name: "ComposableCocoa"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
    .testTarget(
      name: "ComposableExtensionsTests",
      dependencies: [
        .target(name: "ComposableExtensions")
      ]
    ),
  ]
)
