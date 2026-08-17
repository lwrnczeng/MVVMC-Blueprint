import SwiftUI

/// Observable NavigationRouter managing a SwiftUI NavigationPath.
/// Separates SwiftUI view layer from direct NavigationPath mutation.
@MainActor
public final class NavigationRouter: ObservableObject {
    @Published public var path = NavigationPath()
    
    public init() {}
    
    /// Pushes a new route onto the navigation stack.
    public func push<T: Hashable>(_ route: T) {
        path.append(route)
    }
    
    /// Pops the top view from the navigation stack.
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Resets the navigation stack back to root view.
    public func popToRoot() {
        path = NavigationPath()
    }
}
