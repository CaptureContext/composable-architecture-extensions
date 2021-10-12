import Prelude
import ComposableEnvironment

public struct RandomNumberGenerator<Value: Numeric & Comparable> {
  public init(generate: Operations.Generate) {
    self.generate = generate
  }
  
  public var generate: Operations.Generate
}

extension RandomNumberGenerator: DependencyKey {
  public static var defaultValue: RandomNumberGenerator {
    get {
      if RandomNumberGenerator.self is RandomNumberGenerator<Int>.Type {
        return RandomNumberGenerator<Int>.live as! RandomNumberGenerator
      } else {
        fatalError("Unimplemented")
      }
    }
  }
}

extension ComposableDependencies {
  var randomIntGenerator: RandomNumberGenerator<Int> {
    get { self[RandomNumberGenerator<Int>.self] }
    set { self[RandomNumberGenerator<Int>.self] = newValue }
  }
}

extension RandomNumberGenerator {
  public enum Operations {}
}

extension RandomNumberGenerator.Operations {
  public struct Generate: Function {
    public typealias Input = ClosedRange<Value>
    public typealias Output = Value
    
    public init(_ call: @escaping Signature) {
      self.call = call
    }
    
    public var call: Signature
    
    public func callAsFunction(in range: Input) -> Output {
      return call(range)
    }
  }
}

extension RandomNumberGenerator {
  public static func constant(_ value: Value) -> RandomNumberGenerator {
    return RandomNumberGenerator(generate: .init { _ in value })
  }
}

extension RandomNumberGenerator where Value == Int {
  public static var live: RandomNumberGenerator {
    RandomNumberGenerator(generate: .init(Int.random(in:)))
  }
}
