import Foundation

/// Pure Domain Model representing the payment transaction outcome.
public struct PaymentResult: Hashable, Sendable {
    public let transactionId: String
    public let orderId: UUID
    public let totalPaid: Decimal
    public let timestamp: Date
    public let status: PaymentStatus
    
    public enum PaymentStatus: String, Hashable, Sendable {
        case success
        case failed
        case pending
    }
    
    public init(transactionId: String, orderId: UUID, totalPaid: Decimal, timestamp: Date = Date(), status: PaymentStatus) {
        self.transactionId = transactionId
        self.orderId = orderId
        self.totalPaid = totalPaid
        self.timestamp = timestamp
        self.status = status
    }
}
