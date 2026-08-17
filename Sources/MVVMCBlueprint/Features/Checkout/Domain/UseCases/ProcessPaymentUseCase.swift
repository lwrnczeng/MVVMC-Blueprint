import Foundation

public enum PaymentError: Error, LocalizedError, Equatable {
    case invalidAmount
    case paymentDeclined(reason: String)
    case networkFailure
    
    public var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Payment amount must be greater than zero."
        case .paymentDeclined(let reason):
            return "Payment declined: \(reason)"
        case .networkFailure:
            return "Unable to connect to payment gateway."
        }
    }
}

/// Interface for executing payment processing.
public protocol ProcessPaymentUseCaseProtocol: Sendable {
    func execute(orderId: UUID, amount: Decimal) async throws -> PaymentResult
}

/// Pure Business Logic UseCase for processing payments via repository abstraction.
public struct ProcessPaymentUseCase: ProcessPaymentUseCaseProtocol {
    private let repository: OrderRepositoryProtocol
    
    public init(repository: OrderRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(orderId: UUID, amount: Decimal) async throws -> PaymentResult {
        guard amount > 0 else {
            throw PaymentError.invalidAmount
        }
        
        return try await repository.processPayment(orderId: orderId, amount: amount)
    }
}
