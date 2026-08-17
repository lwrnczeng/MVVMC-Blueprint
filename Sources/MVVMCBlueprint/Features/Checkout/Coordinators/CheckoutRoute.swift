import Foundation

/// Defines all navigable routes/screens within the Checkout feature flow.
/// Must conform to Hashable for SwiftUI NavigationPath compatibility.
public enum CheckoutRoute: Hashable, Sendable {
    case inputOrder
    case discount(Order)
    case payment(Order, Discount?)
    case success(PaymentResult)
}
