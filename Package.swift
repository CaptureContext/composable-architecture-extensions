// swift-tools-version:5.9

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
			name: "ComposableExtensions",
			type: .static,
			targets: ["ComposableExtensions"]
		),
		.library(
			name: "ComposableCocoa",
			type: .static,
			targets: ["ComposableCocoa"]
		),
		.library(
			name: "ComposableCore",
			type: .static,
			targets: ["ComposableCore"]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/pointfreeco/swift-composable-architecture.git",
			branch: "observation-beta"
		),
		.package(
			url: "https://github.com/capturecontext/combine-cocoa-navigation.git",
			branch: "navigation-stacks"
		),
		.package(
			url: "https://github.com/capturecontext/swift-declarative-configuration.git",
			.upToNextMinor(from: "0.3.3")
		),
		.package(
			url: "https://github.com/capturecontext/swift-cocoa-extensions.git",
			.upToNextMinor(from: "0.3.4")
		),
		.package(
			url: "https://github.com/capturecontext/swift-foundation-extensions.git",
			.upToNextMinor(from: "0.4.0")
		)
	],
	targets: [
		.target(
			name: "ComposableExtensions",
			dependencies: [
				.target(name: "ComposableCocoa"),
			]
		),
		.target(
			name: "ComposableCocoa",
			dependencies: [
				.target(name: "ComposableCore"),
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
					name: "FunctionalClosures",
					package: "swift-declarative-configuration"
				),
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
			]
		),

		// MARK: - Tests
		.testTarget(
			name: "ComposableCoreTests",
			dependencies: [
				.target(name: "ComposableCore"),
			]
		),
		.testTarget(
			name: "ComposableExtensionsCoreTests",
			dependencies: [
				.target(name: "ComposableExtensionsCore"),
			]
		),
	]
)
