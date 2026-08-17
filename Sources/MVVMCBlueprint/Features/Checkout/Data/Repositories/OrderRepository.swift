import Foundation

/// Concrete implementation of OrderRepositoryProtocol simulating backend network/DB interactions.
public final class OrderRepository: OrderRepositoryProtocol, Sendable {
    
    public init() {}
    
    public func submitOrder(_ order: Order) async throws -> OrderDTO {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let doubleAmount = NSDecimalNumber(decimal: order.subtotal).doubleValue
        return OrderDTO(
            orderId: order.id.uuidString,
            totalAmount: doubleAmount,
            status: "SUBMITTED",
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    public func processPayment(orderId: UUID, amount: Decimal) async throws -> PaymentResult {
        // Simulate network processing
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Simulating success scenario (could add flag for failure testing)
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
