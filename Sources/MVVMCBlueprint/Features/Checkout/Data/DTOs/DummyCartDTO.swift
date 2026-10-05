import Foundation

/// Data Transfer Object matching DummyJSON Carts REST API (https://dummyjson.com/docs/carts).
public struct DummyCartDTO: Codable, Sendable {
    public let id: Int
    public let products: [DummyCartProductDTO]
    public let total: Double
    public let discountedTotal: Double
    public let userId: Int
    public let totalProducts: Int
    public let totalQuantity: Int
    
    public init(
        id: Int,
        products: [DummyCartProductDTO],
        total: Double,
        discountedTotal: Double,
        userId: Int,
        totalProducts: Int,
        totalQuantity: Int
    ) {
        self.id = id
        self.products = products
        self.total = total
        self.discountedTotal = discountedTotal
        self.userId = userId
        self.totalProducts = totalProducts
        self.totalQuantity = totalQuantity
    }
    
    /// Map DummyJSON DTO to pure Domain Model (Order)
    public func toDomain() -> Order {
        let domainItems = products.map { product in
            Order.Item(
                id: UUID(),
                name: product.title,
                price: Decimal(product.price),
                quantity: product.quantity
            )
        }
        
        return Order(
            id: UUID(),
            items: domainItems,
            subtotal: Decimal(total)
        )
    }
}

public struct DummyCartProductDTO: Codable, Sendable {
    public let id: Int
    public let title: String
    public let price: Double
    public let quantity: Int
    public let total: Double
    public let discountPercentage: Double
    public let discountedTotal: Double?
    public let thumbnail: String?
    
    public init(
        id: Int,
        title: String,
        price: Double,
        quantity: Int,
        total: Double,
        discountPercentage: Double,
        discountedTotal: Double? = nil,
        thumbnail: String? = nil
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.quantity = quantity
        self.total = total
        self.discountPercentage = discountPercentage
        self.discountedTotal = discountedTotal
        self.thumbnail = thumbnail
    }
}
