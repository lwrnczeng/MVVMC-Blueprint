import Foundation

/// Concrete implementation of OrderRepositoryProtocol in the Data Layer.
/// Encapsulates DTO decoding/encoding and converts network data to pure Domain Models.
public final class OrderRepository: OrderRepositoryProtocol, Sendable {
    
    public init() {}
    
    public func submitOrder(_ order: Order) async throws -> Order {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let doubleAmount = NSDecimalNumber(decimal: order.subtotal).doubleValue
        let dto = OrderDTO(
            orderId: order.id.uuidString,
            totalAmount: doubleAmount,
            status: "SUBMITTED",
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        // Map DTO to Domain Model before crossing layer boundary into Domain
        return dto.toDomain()
    }
    
    public func processPayment(orderId: UUID, amount: Decimal) async throws -> PaymentResult {
        // Simulate network processing
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let txnId = "TXN-" + UUID().uuidString.prefix(8).uppercased()
        
        return PaymentResult(
            transactionId: txnId,
            orderId: orderId,
            totalPaid: amount,
            timestamp: Date(),
            status: .success
        )
    }
}
