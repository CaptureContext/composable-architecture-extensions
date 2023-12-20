//import ComposableExtensionsCore
//import XCTest
//
//final class TaggableTests: XCTestCase {
//  func testTaggable() {
//    struct First: Equatable {
//      var value: Int = 0
//    }
//    
//    struct Second: Equatable {
//      var value: Int = 0
//    }
//    
//    enum Route: Taggable {
//      case first(First)
//      case second(Second)
//      
//      public var tag: Tag {
//        switch self {
//        case .first:
//          return .first
//          
//        case .second:
//          return .second
//        }
//      }
//      
//      enum Tag: Hashable {
//        case first
//        case second
//      }
//    }
//    
//    let emptyRoute = Optional<Route>.none
//    let firstRoute0 = Route.first(First())
//    let firstRoute1 = Route.first(First(value: 1))
//    let secondRoute = Route.second(Second())
//    
//    XCTAssertEqual(emptyRoute.tag.hashValue, Optional<Route>.Tag.none.hashValue)
//    XCTAssertEqual(firstRoute0.tag, Route.Tag.first)
//    XCTAssertEqual(firstRoute0.tag, firstRoute1.tag)
//    XCTAssertEqual(secondRoute.tag, Route.Tag.second)
//    
//    XCTAssertNotEqual(firstRoute0.tag, secondRoute.tag)
//    XCTAssertNotEqual(firstRoute0.tag, emptyRoute.tag)
//    XCTAssertNotEqual(secondRoute.tag, emptyRoute.tag)
//  }
//  
//  func testTagged() {
//    struct Test: Equatable {
//      var value: Int = 0
//    }
//    
//    struct TaggableTest: Equatable, Taggable {
//      var value: Int = 0
//      
//      var tag: Bool {
//        value.isMultiple(of: 2) ? true : false
//      }
//    }
//    
//    let tagged0 = Tagged(Test(), tag: false) // value is 0, tag is false
//    let tagged1 = Tagged(TaggableTest(value: 1)) // value is 1, tag is 1.isMultiple(of: 2) -> false
//    
//    XCTAssertNotEqual(tagged0[dynamicMember: \.value], tagged1[dynamicMember: \.value])
//    XCTAssertEqual(tagged0.tag, tagged1.tag)
//    XCTAssertEqual(tagged0.hashValue, tagged1.hashValue)
//  }
//}
