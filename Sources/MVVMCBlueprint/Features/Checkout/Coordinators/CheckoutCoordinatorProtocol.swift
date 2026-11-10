import Foundation

/// Protocol defining navigation actions that ViewModels can request from the CheckoutCoordinator.
/// Decouples ViewModels from concrete Coordinator implementation.
@MainActor
public protocol CheckoutCoordinatorProtocol: AnyObject {
    func showDiscount(for order: Order)
    func showPayment(for order: Order, discount: Discount?)
    func showSuccess(result: PaymentResult)
    func finishCheckout()
}
