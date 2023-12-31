import XCTest
@testable import ComposableCocoa
import SwiftUI

@ObservableState
private struct State {
	var text: String
}

private struct FeatureView: ComposableView {
	private let store: Store<State, Never>

	init(_ store: Store<State, Never>) {
		self.store = store
	}

	var body: some View {
		Text(store.text)
	}
}

final class ComposableHostingControllerTests: XCTestCase {
	func testMain() {
		_ = ComposableHostingController<FeatureView>()
	}
}
