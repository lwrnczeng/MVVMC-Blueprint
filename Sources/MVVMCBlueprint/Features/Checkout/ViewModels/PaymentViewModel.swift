import Foundation
import Observation

/// Presentation logic and state management for final payment processing.
@MainActor
@Observable
public final class PaymentViewModel {
    public let order: Order
    public let discount: Discount?
    public let finalAmount: Decimal
    
    public var isLoading: Bool = false
    public var errorMessage: String?
    
    private weak var coordinator: CheckoutCoordinatorProtocol?
    private let processPaymentUseCase: ProcessPaymentUseCaseProtocol
    
    public init(
        order: Order,
        discount: Discount?,
        coordinator: CheckoutCoordinatorProtocol,
        processPaymentUseCase: ProcessPaymentUseCaseProtocol
    ) {
        self.order = order
        self.discount = discount
        self.coordinator = coordinator
        self.processPaymentUseCase = processPaymentUseCase
        self.finalAmount = discount?.finalAmount ?? order.subtotal
    }
    
    public func processPayment() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await processPaymentUseCase.execute(orderId: order.id, amount: finalAmount)
            isLoading = false
            coordinator?.showSuccess(result: result)
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
