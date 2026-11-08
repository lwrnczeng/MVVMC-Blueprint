import SwiftUI

/// Root container view orchestrating multi-feature navigation driven by AppCoordinator.
@MainActor
public struct AppContainerView: View {
    @StateObject private var appCoordinator: AppCoordinator
    
    public init(appCoordinator: AppCoordinator) {
        _appCoordinator = StateObject(wrappedValue: appCoordinator)
    }
    
    public init() {
        self.init(appCoordinator: AppCoordinator())
    }
    
    public var body: some View {
        TabView(selection: $appCoordinator.selectedTab) {
            CatalogContainerView(coordinator: appCoordinator.catalogCoordinator)
                .tabItem {
                    Label("Product Catalog", systemImage: "bag.fill")
                }
                .tag(AppCoordinator.Tab.catalog)
            
            CheckoutContainerView(coordinator: appCoordinator.checkoutCoordinator)
                .tabItem {
                    Label("Checkout", systemImage: "cart.fill")
                }
                .tag(AppCoordinator.Tab.checkout)
        }
        .onAppear {
            appCoordinator.start()
        }
    }
}
