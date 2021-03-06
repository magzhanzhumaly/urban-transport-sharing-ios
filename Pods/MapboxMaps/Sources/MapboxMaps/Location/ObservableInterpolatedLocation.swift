internal protocol ObservableInterpolatedLocationProtocol: AnyObject {
    var value: InterpolatedLocation? { get }
    func notify(with newValue: InterpolatedLocation)
    func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable
}

// This thin wrapper allows injecting ObservableValue without
// making the injected class generic as well. We won't duplicate
// the ObservableValue tests for this class, so it should always
// remain a simple pass-through — do not add additional logic.
internal final class ObservableInterpolatedLocation: ObservableInterpolatedLocationProtocol {
    private let observableValue = ObservableValue<InterpolatedLocation>()

    var value: InterpolatedLocation? {
        return observableValue.value
    }

    internal func notify(with newValue: InterpolatedLocation) {
        observableValue.notify(with: newValue)
    }

    internal func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable {
        return observableValue.observe(with: handler)
    }
}
