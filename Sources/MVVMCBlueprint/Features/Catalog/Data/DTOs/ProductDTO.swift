import Foundation

/// Data Transfer Object matching DummyJSON Products REST API (https://dummyjson.com/docs/products).
public struct ProductsResponseDTO: Codable, Sendable {
    public let products: [ProductDTO]
    public let total: Int
    public let skip: Int
    public let limit: Int
}

public struct ProductDTO: Codable, Sendable {
    public let id: Int
    public let title: String
    public let description: String
    public let category: String
    public let price: Double
    public let rating: Double
    public let thumbnail: String
    
    public init(
        id: Int,
        title: String,
        description: String,
        category: String,
        price: Double,
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
    
    /// Map DTO to pure Domain Entity (Product)
    public func toDomain() -> Product {
        return Product(
            id: id,
            title: title,
            description: description,
            category: category,
            price: Decimal(string: String(price)) ?? Decimal(price),
            rating: rating,
            thumbnail: thumbnail
        )
    }
}
