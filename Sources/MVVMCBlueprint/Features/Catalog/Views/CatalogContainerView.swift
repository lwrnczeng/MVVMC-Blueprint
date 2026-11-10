import SwiftUI

/// Standalone container view for the Catalog feature.
@MainActor
public struct CatalogContainerView: View {
    @State private var coordinator: CatalogCoordinator

    public init(coordinator: CatalogCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    public init() {
        let router = NavigationRouter()
        let coordinator = CatalogCoordinator(router: router)
        self.init(coordinator: coordinator)
    }

    public var body: some View {
        NavigationStack(path: $coordinator.router.path) {
            coordinator.buildView(for: .productList)
                .navigationDestination(for: CatalogRoute.self) { route in
                    coordinator.buildView(for: route)
                }
        }
    }
}
