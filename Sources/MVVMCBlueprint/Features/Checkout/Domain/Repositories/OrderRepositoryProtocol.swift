import Foundation

/// Repository Protocol owned by the Domain layer (Dependency Inversion Principle).
/// Defines the contract for persistence and payment operations using strictly Domain Models.
public protocol OrderRepositoryProtocol: Sendable {
    func submitOrder(_ order: Order) async throws -> Order
    func processPayment(orderId: UUID, amount: Decimal) async throws -> PaymentResult
}
