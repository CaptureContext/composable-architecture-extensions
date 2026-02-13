// swift-tools-version: 6.0

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
			name: "ComposableSwiftUI",
			type: .static,
			targets: ["ComposableSwiftUI"]
		),
		.library(
			name: "ComposableCore",
			type: .static,
			targets: ["ComposableCore"]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/apple/swift-docc-plugin.git",
			from: "1.4.0"
		),
		.package(
			url: "https://github.com/pointfreeco/swift-composable-architecture.git",
			.upToNextMajor(from: "1.23.0")
		),
		.package(
			url: "https://github.com/capturecontext/swift-declarative-configuration.git",
			.upToNextMinor(from: "0.5.4")
		),
		.package(
			url: "https://github.com/capturecontext/swift-cocoa-extensions.git",
			.upToNextMinor(from: "0.5.0-alpha.6")
		),
		.package(
			url: "https://github.com/capturecontext/swift-foundation-extensions.git",
			.upToNextMinor(from: "0.6.0")
		)
	],
	targets: [
		.target(
			name: "ComposableExtensions",
			dependencies: [
				.target(name: "ComposableCocoa"),
				.target(name: "ComposableSwiftUI")
			]
		),
		.target(
			name: "ComposableCocoa",
			dependencies: [
				.target(name: "ComposableCore"),
				.product(
					name: "CocoaExtensionsMacros",
					package: "swift-cocoa-extensions"
				)
			]
		),
		.target(
			name: "ComposableSwiftUI",
			dependencies: [
				.target(name: "ComposableCore"),
				.target(name: "_ComposableSwiftUICore"),
				.product(
					name: "CocoaExtensionsMacros",
					package: "swift-cocoa-extensions"
				)
			]
		),
		.target(
			// Underscore removes module from autocomplete
			// Separate module is used to avoid exporting SwiftUI
			// from ComposableExtensions module
			name: "_ComposableSwiftUICore",
			dependencies: [
				.product(
					name: "ComposableArchitecture",
					package: "swift-composable-architecture"
				)
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
	],
	swiftLanguageModes: [.v6]
)
