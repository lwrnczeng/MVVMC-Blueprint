import Foundation

/// Repository Protocol acting as boundary interface between Data and Domain layers.
public protocol OrderRepositoryProtocol: Sendable {
    func submitOrder(_ order: Order) async throws -> OrderDTO
    func processPayment(orderId: UUID, amount: Decimal) async throws -> PaymentResult
}
