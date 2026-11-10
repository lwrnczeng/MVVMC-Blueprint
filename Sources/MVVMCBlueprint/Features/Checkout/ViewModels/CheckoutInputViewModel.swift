import Foundation
import Observation

/// Presentation logic and state management for creating or fetching an order.
@MainActor
@Observable
public final class CheckoutInputViewModel {
    public var itemName: String = ""
    public var itemPriceText: String = ""
    public var quantity: Int = 1
    public var isLoadingCart: Bool = false
    public var errorMessage: String?
    
    private weak var coordinator: CheckoutCoordinatorProtocol?
    private let repository: OrderRepositoryProtocol
    
    public init(
        coordinator: CheckoutCoordinatorProtocol,
        repository: OrderRepositoryProtocol = OrderRepository()
    ) {
        self.coordinator = coordinator
        self.repository = repository
    }
    
    /// Fetches a live sample cart from DummyJSON REST API (https://dummyjson.com/carts/1)
    public func fetchDummyCart(id: Int = 1) async {
        isLoadingCart = true
        errorMessage = nil
        
        do {
            let fetchedOrder = try await repository.fetchCart(id: id)
            isLoadingCart = false
            coordinator?.showDiscount(for: fetchedOrder)
        } catch {
            isLoadingCart = false
            errorMessage = "Failed to fetch DummyJSON cart: \(error.localizedDescription)"
        }
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
