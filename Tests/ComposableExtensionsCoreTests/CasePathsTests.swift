import ComposableExtensionsCore
import XCTest

final class CasePathsTests: XCTestCase {
  func testIfCaseLetEmbed() {
    enum Test: Equatable {
      case a(Int)
      case b(Int)
      case c(Bool)
      
      var a: Int? {
        get { (/Self.a).extract(from: self) }
        set { (/Self.a).ifCaseLetEmbed(newValue, in: &self) }
      }
      
      var b: Int? {
        get { (/Self.b).extract(from: self) }
        set { (/Self.b).ifCaseLetEmbed(newValue, in: &self) }
      }
      
      var c: Bool? {
        get { (/Self.c).extract(from: self) }
        set { (/Self.c).ifCaseLetEmbed(newValue, in: &self) }
      }
    }
    
    var value: Test = .a(0)

    do {
      XCTAssertEqual(value.a, 0)
      XCTAssertEqual(value.b, nil)
      XCTAssertEqual(value.c, nil)
    }
    
    do {
      value.a = 1
      XCTAssertEqual(value, .a(1))
      XCTAssertEqual(value.b, nil)
      XCTAssertEqual(value.c, nil)
    }
    
    do {
      value.a? += 1
      XCTAssertEqual(value, .a(2))
      XCTAssertEqual(value.b, nil)
      XCTAssertEqual(value.c, nil)
    }
    
    do {
      value.b = 0
      XCTAssertEqual(value, .a(2))
      XCTAssertEqual(value.b, nil)
      XCTAssertEqual(value.c, nil)
    }
    
    do {
      value.c = true
      XCTAssertEqual(value, .a(2))
      XCTAssertEqual(value.b, nil)
      XCTAssertEqual(value.c, nil)
    }
    
    do {
      value = .b(0)
      XCTAssertEqual(value.a, nil)
      XCTAssertEqual(value.b, 0)
      XCTAssertEqual(value.c, nil)
    }
    
    do {
      value.b = 1
      XCTAssertEqual(value.a, nil)
      XCTAssertEqual(value.b, 1)
      XCTAssertEqual(value.c, nil)
    }
  }
  
  func testCaseMarker() {
    enum Test: Equatable {
      case a(Int)
      case b(Int)
      case c(Bool)
    }
    
    let aMarker = CaseMarker(for: /Test.a)
    let bMarker = CaseMarker(for: /Test.b)
    let cMarker = CaseMarker(for: /Test.c)
    
    var value: Test = .a(0)

    do {
      XCTAssertTrue(aMarker.matches(value))
      XCTAssertFalse(bMarker.matches(value))
      XCTAssertFalse(cMarker.matches(value))
    }
    
    do {
      value = .b(0)
      XCTAssertFalse(aMarker.matches(value))
      XCTAssertTrue(bMarker.matches(value))
      XCTAssertFalse(cMarker.matches(value))
    }
    
    do {
      value = .c(false)
      XCTAssertFalse(aMarker.matches(value))
      XCTAssertFalse(bMarker.matches(value))
      XCTAssertTrue(cMarker.matches(value))
    }
  }
}
