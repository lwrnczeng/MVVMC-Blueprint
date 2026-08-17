import Foundation

/// Pure Domain Model representing a customer order.
/// Immutable value type, conforming to Sendable for Swift concurrency safety.
public struct Order: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let items: [Item]
    public let subtotal: Decimal
    public var promoCode: String?
    
    public struct Item: Identifiable, Hashable, Sendable {
        public let id: UUID
        public let name: String
        public let price: Decimal
        public let quantity: Int
        
        public init(id: UUID = UUID(), name: String, price: Decimal, quantity: Int) {
            self.id = id
            self.name = name
            self.price = price
            self.quantity = quantity
        }
    }
    
    public init(id: UUID = UUID(), items: [Item], subtotal: Decimal, promoCode: String? = nil) {
        self.id = id
        self.items = items
        self.subtotal = subtotal
        self.promoCode = promoCode
    }
}
