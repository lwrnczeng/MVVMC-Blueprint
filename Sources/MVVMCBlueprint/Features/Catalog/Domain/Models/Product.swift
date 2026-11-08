import Foundation

/// Pure Domain Entity representing a Product in the Catalog.
public struct Product: Identifiable, Equatable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let description: String
    public let category: String
    public let price: Decimal
    public let rating: Double
    public let thumbnail: String
    
    public init(
        id: Int,
        title: String,
        description: String,
        category: String,
        price: Decimal,
        rating: Double,
        thumbnail: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.price = price
        self.rating = rating
        self.thumbnail = thumbnail
    }
}
