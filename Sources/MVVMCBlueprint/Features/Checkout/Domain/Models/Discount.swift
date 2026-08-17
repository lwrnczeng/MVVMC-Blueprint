import Foundation

/// Pure Domain Model representing a discount calculation result.
public struct Discount: Hashable, Sendable {
    public let code: String
    public let percentage: Decimal
    public let amountSaved: Decimal
    public let finalAmount: Decimal
    
    public init(code: String, percentage: Decimal, amountSaved: Decimal, finalAmount: Decimal) {
        self.code = code
        self.percentage = percentage
        self.amountSaved = amountSaved
        self.finalAmount = finalAmount
    }
}
