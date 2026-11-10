import Foundation
import Observation

/// Presentation logic and state management for promo code entry & calculation.
@MainActor
@Observable
public final class DiscountViewModel {
    public let order: Order
    
    public var promoCodeInput: String = ""
    public var appliedDiscount: Discount?
    public var errorMessage: String?
    
    private weak var coordinator: CheckoutCoordinatorProtocol?
    private let calculateDiscountUseCase: CalculateDiscountUseCaseProtocol
    
    public init(
        order: Order,
        coordinator: CheckoutCoordinatorProtocol,
        calculateDiscountUseCase: CalculateDiscountUseCaseProtocol
    ) {
        self.order = order
        self.coordinator = coordinator
        self.calculateDiscountUseCase = calculateDiscountUseCase
    }
    
    public func applyPromoCode() {
        guard !promoCodeInput.isEmpty else {
            errorMessage = "Please enter a promo code."
            return
        }
        
        do {
            let discount = try calculateDiscountUseCase.execute(subtotal: order.subtotal, promoCode: promoCodeInput)
            self.appliedDiscount = discount
            self.errorMessage = nil
        } catch {
            self.appliedDiscount = nil
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func skipOrProceedToPayment() {
        coordinator?.showPayment(for: order, discount: appliedDiscount)
    }
}
