import Foundation
import Combine

/// Presentation logic and state management for creating an initial order.
@MainActor
public final class CheckoutInputViewModel: ObservableObject {
    @Published public var itemName: String = ""
    @Published public var itemPriceText: String = ""
    @Published public var quantity: Int = 1
    @Published public var errorMessage: String?
    
    private weak var coordinator: CheckoutCoordinatorProtocol?
    
    public init(coordinator: CheckoutCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    public func proceedToDiscount() {
        guard !itemName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter an item name."
            return
        }
        
        guard let price = Decimal(string: itemPriceText), price > 0 else {
            errorMessage = "Please enter a valid positive price."
            return
        }
        
        errorMessage = nil
        
        let item = Order.Item(name: itemName, price: price, quantity: quantity)
        let subtotal = price * Decimal(quantity)
        let order = Order(items: [item], subtotal: subtotal)
        
        coordinator?.showDiscount(for: order)
    }
}
