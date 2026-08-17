import XCTest
@testable import MVVMCBlueprint

@MainActor
final class MockCheckoutCoordinator: CheckoutCoordinatorProtocol {
    var showDiscountCalled = false
    var lastOrder: Order?
    
    var showPaymentCalled = false
    var showSuccessCalled = false
    var finishCheckoutCalled = false
    
    func showDiscount(for order: Order) {
        showDiscountCalled = true
        lastOrder = order
    }
    
    func showPayment(for order: Order, discount: Discount?) {
        showPaymentCalled = true
    }
    
    func showSuccess(result: PaymentResult) {
        showSuccessCalled = true
    }
    
    func finishCheckout() {
        finishCheckoutCalled = true
    }
}

@MainActor
final class CheckoutInputViewModelTests: XCTestCase {
    private var sut: CheckoutInputViewModel!
    private var mockCoordinator: MockCheckoutCoordinator!
    
    override func setUp() {
        super.setUp()
        mockCoordinator = MockCheckoutCoordinator()
        sut = CheckoutInputViewModel(coordinator: mockCoordinator)
    }
    
    override func tearDown() {
        sut = nil
        mockCoordinator = nil
        super.tearDown()
    }
    
    func testProceedToDiscount_withValidInputs_triggersCoordinatorShowDiscount() {
        // Given
        sut.itemName = "Test Book"
        sut.itemPriceText = "25.0"
        sut.quantity = 2
        
        // When
        sut.proceedToDiscount()
        
        // Then
        XCTAssertTrue(mockCoordinator.showDiscountCalled)
        XCTAssertEqual(mockCoordinator.lastOrder?.subtotal, 50.0)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testProceedToDiscount_withEmptyItemName_showsErrorMessage() {
        // Given
        sut.itemName = ""
        sut.itemPriceText = "25.0"
        
        // When
        sut.proceedToDiscount()
        
        // Then
        XCTAssertFalse(mockCoordinator.showDiscountCalled)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func testProceedToDiscount_withInvalidPrice_showsErrorMessage() {
        // Given
        sut.itemName = "Book"
        sut.itemPriceText = "-10"
        
        // When
        sut.proceedToDiscount()
        
        // Then
        XCTAssertFalse(mockCoordinator.showDiscountCalled)
        XCTAssertNotNil(sut.errorMessage)
    }
}
