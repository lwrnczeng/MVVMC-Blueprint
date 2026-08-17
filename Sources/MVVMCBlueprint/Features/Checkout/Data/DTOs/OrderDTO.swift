import Foundation

/// Data Transfer Object representing network JSON response or database entity for an Order.
public struct OrderDTO: Codable, Sendable {
    public let orderId: String
    public let totalAmount: Double
    public let status: String
    public let createdAt: String
    
    public init(orderId: String, totalAmount: Double, status: String, createdAt: String) {
        self.orderId = orderId
        self.totalAmount = totalAmount
        self.status = status
        self.createdAt = createdAt
    }
    
    /// Map DTO to pure Domain Model
    public func toDomain() -> Order {
        return Order(
            id: UUID(uuidString: orderId) ?? UUID(),
            items: [],
            subtotal: Decimal(totalAmount)
        )
    }
}
