import CombineExtensions
import ComposableArchitecture

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

  public static let background: NoOptionsSchedulerOf<DispatchQueue> =
    AnySchedulerOf<DispatchQueue>(
      DispatchQueue(
        label: "tca.background",
        qos: .default
      )
    ).ignoreOptions()

  private(set) public static var eventHandling: AnyScheduler =
    UIScheduler.shared.eraseToAnyScheduler()
}
