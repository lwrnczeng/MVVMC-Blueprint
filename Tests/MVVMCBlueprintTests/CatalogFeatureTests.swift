import XCTest
@testable import MVVMCBlueprint

@MainActor
final class MockCatalogCoordinator: CatalogCoordinatorProtocol {
    var showProductDetailCalled = false
    var selectedProduct: Product?
    
    var proceedToCheckoutCalled = false
    var checkoutProduct: Product?
    
    func showProductDetail(_ product: Product) {
        showProductDetailCalled = true
        selectedProduct = product
    }
    
    func proceedToCheckout(with product: Product) {
        proceedToCheckoutCalled = true
        checkoutProduct = product
    }
}

final class MockProductRepository: ProductRepositoryProtocol, @unchecked Sendable {
    var mockProducts: [Product] = []
    var shouldFail = false
    
    func fetchProducts() async throws -> [Product] {
        if shouldFail {
            throw NetworkError.serverError
        }
        return mockProducts
    }
    
    func fetchProductDetails(id: Int) async throws -> Product {
        if shouldFail {
            throw NetworkError.serverError
        }
        return mockProducts.first(where: { $0.id == id }) ?? mockProducts[0]
    }
}

@MainActor
final class CatalogFeatureTests: XCTestCase {
    
    func testCatalogViewModel_loadProducts_success_populatesSortedProducts() async {
        // Given
        let mockRepo = MockProductRepository()
        mockRepo.mockProducts = [
            Product(id: 1, title: "Item B", description: "Desc", category: "Cat", price: 10, rating: 3.5, thumbnail: ""),
            Product(id: 2, title: "Item A", description: "Desc", category: "Cat", price: 20, rating: 4.8, thumbnail: "")
        ]
        let useCase = FetchProductsUseCase(repository: mockRepo)
        let mockCoordinator = MockCatalogCoordinator()
        let vm = CatalogViewModel(coordinator: mockCoordinator, fetchProductsUseCase: useCase)
        
        // When
        await vm.loadProducts()
        
        // Then
        XCTAssertEqual(vm.products.count, 2)
        XCTAssertEqual(vm.products.first?.title, "Item A") // High rating sorted first
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }
    
    func testCatalogViewModel_selectProduct_triggersCoordinatorProductDetail() {
        // Given
        let mockRepo = MockProductRepository()
        let useCase = FetchProductsUseCase(repository: mockRepo)
        let mockCoordinator = MockCatalogCoordinator()
        let vm = CatalogViewModel(coordinator: mockCoordinator, fetchProductsUseCase: useCase)
        let product = Product(id: 1, title: "Book", description: "Desc", category: "Cat", price: 10, rating: 4.5, thumbnail: "")
        
        // When
        vm.selectProduct(product)
        
        // Then
        XCTAssertTrue(mockCoordinator.showProductDetailCalled)
        XCTAssertEqual(mockCoordinator.selectedProduct?.title, "Book")
    }
    
    func testCatalogCoordinator_showProductDetail_pushesRouteToRouter() {
        // Given
        let router = NavigationRouter()
        let coordinator = CatalogCoordinator(router: router)
        let product = Product(id: 1, title: "Book", description: "Desc", category: "Cat", price: 10, rating: 4.5, thumbnail: "")
        
        // When
        coordinator.showProductDetail(product)
        
        // Then
        XCTAssertEqual(router.path.count, 1)
    }
    
    func testAppCoordinator_catalogDidSelectProductForCheckout_launchesCheckoutFlow() {
        // Given
        let router = NavigationRouter()
        let appCoordinator = AppCoordinator(router: router)
        let product = Product(id: 101, title: "Smartphone", description: "Flagship phone", category: "tech", price: 999.0, rating: 4.9, thumbnail: "")
        
        // When
        appCoordinator.catalogDidSelectProductForCheckout(product)
        
        // Then
        XCTAssertEqual(appCoordinator.childCoordinators.count, 2)
        XCTAssertTrue(appCoordinator.childCoordinators.contains { $0 is CheckoutCoordinator })
        XCTAssertEqual(appCoordinator.selectedTab, .checkout)
        XCTAssertEqual(appCoordinator.checkoutCoordinator.router.path.count, 1)
    }
}
