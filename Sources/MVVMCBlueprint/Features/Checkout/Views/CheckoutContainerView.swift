import SwiftUI
import Foundation

/// Root Container View in MVVM-C pattern.
/// Binds SwiftUI's NavigationStack to the Coordinator's NavigationRouter.
@MainActor
public struct CheckoutContainerView: View {
    @StateObject private var coordinator: CheckoutCoordinator
    @StateObject private var router: NavigationRouter
    
    public init(coordinator: CheckoutCoordinator) {
        _coordinator = StateObject(wrappedValue: coordinator)
        _router = StateObject(wrappedValue: coordinator.router)
    }
    
    public init() {
        let coordinator = CheckoutCoordinator()
        self.init(coordinator: coordinator)
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            coordinator.buildView(for: .inputOrder)
                .navigationDestination(for: CheckoutRoute.self) { route in
                    coordinator
                        .buildView(for: route)
                        .onAppear {
                            print("[Navigation] CheckoutRoute ->", String(describing: route))
                        }
                }
        }
    }
}

