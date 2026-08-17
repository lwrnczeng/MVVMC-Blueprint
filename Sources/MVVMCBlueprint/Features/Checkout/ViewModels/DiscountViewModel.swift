import Foundation
import Combine

/// Presentation logic and state management for promo code entry & calculation.
@MainActor
public final class DiscountViewModel: ObservableObject {
    public let order: Order
    
    @Published public var promoCodeInput: String = ""
    @Published public var appliedDiscount: Discount?
    @Published public var errorMessage: String?
    
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
