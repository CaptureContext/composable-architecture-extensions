// swift-tools-version:5.9

import PackageDescription

let package = Package(
	name: "composable-architecture-extensions",
	platforms: [
		.iOS(.v13),
		.macOS(.v11),
		.macCatalyst(.v13),
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
			.upToNextMajor(from: "1.8.2")
		),
		.package(
			url: "https://github.com/capturecontext/combine-cocoa-navigation.git",
			branch: "navigation-stacks"
		),
//		.package(path: "../combine-cocoa-navigation"),
		.package(
			url: "https://github.com/capturecontext/swift-declarative-configuration.git",
			.upToNextMinor(from: "0.3.3")
		),
		.package(
			url: "https://github.com/capturecontext/swift-cocoa-extensions.git",
			.upToNextMinor(from: "0.4.0")
		),
		.package(
			url: "https://github.com/capturecontext/swift-foundation-extensions.git",
			.upToNextMinor(from: "0.5.0")
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
					name: "CocoaExtensionsMacros",
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
					name: "FoundationExtensionsMacros",
					package: "swift-foundation-extensions"
				),
			]
		),

		// MARK: - Tests
		.testTarget(
			name: "ComposableCocoaTests",
			dependencies: [
				.target(name: "ComposableCocoa"),
			]
		),
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
