import CombineExtensions
import ComposableDependencies
import Foundation

// MARK: - EventHandlingScheduler

extension AnyScheduler
where
  Self.SchedulerTimeType == DispatchQueue.SchedulerTimeType,
  Self.SchedulerOptions == Never
{
  public static func setEventHandlingScheduler(
    _ scheduler: NoOptionsSchedulerOf<DispatchQueue>
  ) {
    self.eventHandling = scheduler
  }
  
  private(set) public static var eventHandling: AnyScheduler =
    UIScheduler.shared.eraseToAnyScheduler()
}

private enum EventHandlingSchedulerKey: DependencyKey {
  public static var defaultValue: NoOptionsSchedulerOf<DispatchQueue> { .eventHandling }
}

extension Dependencies {
  public var eventHandlingScheduler: NoOptionsSchedulerOf<DispatchQueue> {
    get { self[EventHandlingSchedulerKey.self] }
    set { self[EventHandlingSchedulerKey.self] = newValue }
  }
}
