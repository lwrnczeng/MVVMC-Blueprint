import Observation
import SwiftUI

/// Concrete Coordinator managing navigation within the Catalog Feature.
@MainActor
@Observable
public final class CatalogCoordinator: Coordinator, CatalogCoordinatorProtocol {
    public var childCoordinators: [Coordinator] = []
    public var router: NavigationRouter
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

    public func start() {}

    public func showProductDetail(_ product: Product) {
        router.push(CatalogRoute.productDetail(product))
    }

    public func proceedToCheckout(with product: Product) {
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
