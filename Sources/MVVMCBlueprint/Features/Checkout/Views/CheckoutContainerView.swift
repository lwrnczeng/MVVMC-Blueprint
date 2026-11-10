import SwiftUI

/// Root Container View in MVVM-C pattern.
/// Binds SwiftUI's NavigationStack to the Coordinator's NavigationRouter.
@MainActor
public struct CheckoutContainerView: View {
    @State private var coordinator: CheckoutCoordinator

    public init(coordinator: CheckoutCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    public init() {
        let coordinator = CheckoutCoordinator()
        self.init(coordinator: coordinator)
    }

    public var body: some View {
        NavigationStack(path: $coordinator.router.path) {
            coordinator.buildView(for: .inputOrder)
                .navigationDestination(for: CheckoutRoute.self) { route in
                    coordinator.buildView(for: route)
                }
        }
    }
}
