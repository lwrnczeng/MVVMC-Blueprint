import XCTest
@testable import MVVMCBlueprint

@MainActor
final class CheckoutCoordinatorTests: XCTestCase {
    private var sut: CheckoutCoordinator!
    private var router: NavigationRouter!
    
    override func setUp() {
        super.setUp()
        router = NavigationRouter()
        sut = CheckoutCoordinator(
            router: router,
            repository: OrderRepository(),
            calculateDiscountUseCase: CalculateDiscountUseCase()
        )
    }
    
    override func tearDown() {
        sut = nil
        router = nil
        super.tearDown()
    }
    
    func testShowDiscount_pushesDiscountRouteToRouter() {
        // Given
        let order = Order(items: [], subtotal: 50.0)
        
        // When
        sut.showDiscount(for: order)
        
        // Then
        XCTAssertEqual(router.path.count, 1)
    }
    
    func testFinishCheckout_resetsNavigationPath() {
        // Given
        let order = Order(items: [], subtotal: 50.0)
        sut.showDiscount(for: order)
        XCTAssertEqual(router.path.count, 1)
        
        // When
        sut.finishCheckout()
        
        // Then
        XCTAssertEqual(router.path.count, 0)
    }
}
