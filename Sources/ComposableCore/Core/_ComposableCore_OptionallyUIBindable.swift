import SwiftNavigation
import Perception

@propertyWrapper
public struct _ComposableCore_OptionallyUIBindable<Value: AnyObject & Perceptible> {
	private var _storage: UIBindable<Value>?
	private let fileID: StaticString
	private let filePath: StaticString
	private let line: UInt
	private let column: UInt

	public var wrappedValue: Value? {
		get { _storage?.wrappedValue }
		set {
			guard let newValue else {
				_storage = nil
				return
			}

			guard _storage != nil else {
				_storage = UIBindable(
					newValue,
					fileID: fileID,
					filePath: filePath,
					line: line,
					column: column
				)
				return
			}

			_storage?.wrappedValue = newValue
		}
	}

	public var projectedValue: UIBindable<Value>? {
		get { _storage }
		set { _storage = newValue }
	}

	public init(
		_ wrappedValue: Value? = nil,
		fileID: StaticString = #fileID,
		filePath: StaticString = #filePath,
		line: UInt = #line,
		column: UInt = #column
	) {
		self.fileID = fileID
		self.filePath = filePath
		self.line = line
		self.column = column

		if let wrappedValue {
			self.wrappedValue = wrappedValue
		}
	}
}
