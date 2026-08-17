import Foundation
import Combine

/// Presentation logic and state management for final payment processing.
@MainActor
public final class PaymentViewModel: ObservableObject {
    public let order: Order
    public let discount: Discount?
    public let finalAmount: Decimal
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
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
