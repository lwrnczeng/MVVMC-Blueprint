import XCTest
@testable import MVVMCBlueprint

final class CalculateDiscountUseCaseTests: XCTestCase {
    private var sut: CalculateDiscountUseCase!
    
    override func setUp() {
        super.setUp()
        sut = CalculateDiscountUseCase()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCalculateDiscount_withValidCode_returnsCorrectDiscount() throws {
        // Given
        let subtotal: Decimal = 100.0
        let promoCode = "SAVE20"
        
        // When
        let discount = try sut.execute(subtotal: subtotal, promoCode: promoCode)
        
        // Then
        XCTAssertEqual(discount.code, "SAVE20")
        XCTAssertEqual(discount.percentage, 0.20)
        XCTAssertEqual(discount.amountSaved, 20.0)
        XCTAssertEqual(discount.finalAmount, 80.0)
    }
    
    func testCalculateDiscount_withInvalidCode_throwsError() {
        // Given
        let subtotal: Decimal = 100.0
        let promoCode = "INVALID_CODE"
        
        // Then
        XCTAssertThrowsError(try sut.execute(subtotal: subtotal, promoCode: promoCode)) { error in
            XCTAssertEqual(error as? DiscountError, DiscountError.invalidPromoCode)
        }
    }
    
    func testCalculateDiscount_withZeroSubtotal_throwsSubtotalTooLowError() {
        // Given
        let subtotal: Decimal = 0.0
        let promoCode = "SAVE10"
        
        // Then
        XCTAssertThrowsError(try sut.execute(subtotal: subtotal, promoCode: promoCode)) { error in
            XCTAssertEqual(error as? DiscountError, DiscountError.subtotalTooLow)
        }
    }
}
