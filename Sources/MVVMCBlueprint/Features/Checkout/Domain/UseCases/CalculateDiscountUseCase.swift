import Foundation

public enum DiscountError: Error, LocalizedError, Equatable {
    case invalidPromoCode
    case subtotalTooLow
    
    public var errorDescription: String? {
        switch self {
        case .invalidPromoCode:
            return "The promotional code entered is invalid or expired."
        case .subtotalTooLow:
            return "Order subtotal must be greater than zero to apply discount."
        }
    }
}

/// Interface for calculating discount business logic.
public protocol CalculateDiscountUseCaseProtocol: Sendable {
    func execute(subtotal: Decimal, promoCode: String) throws -> Discount
}

/// Pure Business Logic UseCase for calculating promotional discounts.
public struct CalculateDiscountUseCase: CalculateDiscountUseCaseProtocol {
    
    public init() {}
    
    public func execute(subtotal: Decimal, promoCode: String) throws -> Discount {
        guard subtotal > 0 else {
            throw DiscountError.subtotalTooLow
        }
        
        let cleanedCode = promoCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        let percentage: Decimal
        switch cleanedCode {
        case "SAVE10":
            percentage = 0.10
        case "SAVE20":
            percentage = 0.20
        case "VIP50":
            percentage = 0.50
        default:
            throw DiscountError.invalidPromoCode
        }
        
        let amountSaved = subtotal * percentage
        let finalAmount = subtotal - amountSaved
        
        return Discount(
            code: cleanedCode,
            percentage: percentage,
            amountSaved: amountSaved,
            finalAmount: finalAmount
        )
    }
}
