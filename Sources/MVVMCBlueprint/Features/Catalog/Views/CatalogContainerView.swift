import SwiftUI

/// Standalone container view for the Catalog feature.
@MainActor
public struct CatalogContainerView: View {
    @StateObject private var coordinator: CatalogCoordinator
    @StateObject private var router: NavigationRouter
    
    public init(coordinator: CatalogCoordinator) {
        _coordinator = StateObject(wrappedValue: coordinator)
        _router = StateObject(wrappedValue: coordinator.router)
    }
    
    public init() {
        let router = NavigationRouter()
        let coordinator = CatalogCoordinator(router: router)
        self.init(coordinator: coordinator)
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            coordinator.buildView(for: .productList)
                .navigationDestination(for: CatalogRoute.self) { route in
                    coordinator.buildView(for: route)
                }
        }
    }
}
