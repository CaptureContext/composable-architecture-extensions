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
      name: "ComposableExtensions",
      targets: ["ComposableExtensions"]),
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
    )
  ],
  targets: [
    .target(
      name: "ComposableExtensions",
      dependencies: [
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
    .testTarget(
      name: "ComposableExtensionsTests",
      dependencies: [
        .target(name: "ComposableExtensions")
      ]
    ),
  ]
)
