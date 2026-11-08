import SwiftUI

@MainActor
public protocol CatalogCoordinatorProtocol: AnyObject {
    func showProductDetail(_ product: Product)
    func proceedToCheckout(with product: Product)
}

/// Concrete Coordinator managing navigation within the Catalog Feature.
@MainActor
public final class CatalogCoordinator: Coordinator, CatalogCoordinatorProtocol, ObservableObject {
    public var childCoordinators: [Coordinator] = []
    public let router: NavigationRouter
    public weak var delegate: CatalogCoordinatorDelegate?
    
    private let fetchProductsUseCase: FetchProductsUseCaseProtocol
    private var catalogViewModel: CatalogViewModel!
    
    public init(
        router: NavigationRouter,
        fetchProductsUseCase: FetchProductsUseCaseProtocol = FetchProductsUseCase(repository: ProductRepository())
    ) {
        self.router = router
        self.fetchProductsUseCase = fetchProductsUseCase
        self.catalogViewModel = CatalogViewModel(coordinator: self, fetchProductsUseCase: fetchProductsUseCase)
    }
    
    public func start() {
        // Root flow start
    }
    
    public func showProductDetail(_ product: Product) {
        router.push(CatalogRoute.productDetail(product))
    }
    
    public func proceedToCheckout(with product: Product) {
        // Delegate cross-feature navigation to AppCoordinator
        delegate?.catalogDidSelectProductForCheckout(product)
    }
    
    @ViewBuilder
    public func buildView(for route: CatalogRoute) -> some View {
        switch route {
        case .productList:
            ProductListView(viewModel: catalogViewModel)
        case .productDetail(let product):
            ProductDetailView(product: product, coordinator: self)
        }
    }
}
