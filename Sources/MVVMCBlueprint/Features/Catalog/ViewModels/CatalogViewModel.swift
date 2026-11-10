import Foundation
import Observation

/// Presentation logic and state management for browsing catalog products.
@MainActor
@Observable
public final class CatalogViewModel {
    public var products: [Product] = []
    public var isLoading = false
    public var errorMessage: String?

    private weak var coordinator: CatalogCoordinatorProtocol?
    private let fetchProductsUseCase: FetchProductsUseCaseProtocol

    public init(
        coordinator: CatalogCoordinatorProtocol,
        fetchProductsUseCase: FetchProductsUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.fetchProductsUseCase = fetchProductsUseCase
    }

    public func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            products = try await fetchProductsUseCase.execute()
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }

        isLoading = false
    }

    public func selectProduct(_ product: Product) {
        coordinator?.showProductDetail(product)
    }
}
