import Foundation

/// Base protocol defining the core lifecycle and interface of a Coordinator in MVVM-C.
/// Coordinators own navigation flow, view instantiation, dependency injection, and child flow lifecycles.
@MainActor
public protocol Coordinator: AnyObject {
    /// Array of child coordinators to prevent memory deallocation of sub-flows.
    var childCoordinators: [Coordinator] { get set }
    
    /// Starts the coordinator's primary navigation flow.
    func start()
    
    /// Adds a child coordinator to the array.
    func addChild(_ coordinator: Coordinator)
    
    /// Removes a child coordinator from the array upon completion.
    func removeChild(_ coordinator: Coordinator)
}

public extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
