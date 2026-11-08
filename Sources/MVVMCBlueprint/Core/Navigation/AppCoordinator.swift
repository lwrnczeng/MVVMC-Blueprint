import SwiftUI

/// Root Coordinator orchestrating feature modules and handling cross-feature navigation.
@MainActor
public final class AppCoordinator: Coordinator, CatalogCoordinatorDelegate, ObservableObject {
    public var childCoordinators: [Coordinator] = []
    @Published public var router: NavigationRouter
    
    public private(set) var catalogCoordinator: CatalogCoordinator!
    public private(set) var checkoutCoordinator: CheckoutCoordinator!
    
    @Published public var selectedTab: Tab = .catalog
    
    public enum Tab: Hashable, Sendable {
        case catalog
        case checkout
    }
    
    public convenience init() {
        self.init(
            router: NavigationRouter(),
            catalogRouter: NavigationRouter(),
            checkoutRouter: NavigationRouter()
        )
    }
    
    public convenience init(router: NavigationRouter) {
        self.init(
            router: router,
            catalogRouter: NavigationRouter(),
            checkoutRouter: NavigationRouter()
        )
    }
    
    public init(
        router: NavigationRouter,
        catalogRouter: NavigationRouter,
        checkoutRouter: NavigationRouter
    ) {
        self.router = router
        self.catalogCoordinator = CatalogCoordinator(router: catalogRouter)
        self.checkoutCoordinator = CheckoutCoordinator(router: checkoutRouter)
        
        self.catalogCoordinator.delegate = self
        addChild(catalogCoordinator)
        addChild(checkoutCoordinator)
    }
    
    public func start() {
        catalogCoordinator.start()
        checkoutCoordinator.start()
    }
    
    // MARK: - CatalogCoordinatorDelegate (Cross-Feature Navigation)
    public func catalogDidSelectProductForCheckout(_ product: Product) {
        let orderItem = Order.Item(
            id: UUID(),
            name: product.title,
            price: product.price,
            quantity: 1
        )
        let order = Order(
            id: UUID(),
            items: [orderItem],
            subtotal: product.price
        )
        
        // Switch tab to checkout and launch flow with selected product
        selectedTab = .checkout
        checkoutCoordinator.showDiscount(for: order)
    }
}
