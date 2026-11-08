import Foundation
import Combine

/// Presentation logic and state management for browsing catalog products.
@MainActor
public final class CatalogViewModel: ObservableObject {
    @Published public var products: [Product] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
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
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    public func selectProduct(_ product: Product) {
        coordinator?.showProductDetail(product)
    }
}
