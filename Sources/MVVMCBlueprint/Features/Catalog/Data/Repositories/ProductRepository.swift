import Foundation

/// Concrete implementation of ProductRepositoryProtocol in the Data Layer.
public final class ProductRepository: ProductRepositoryProtocol, Sendable {
    private let networkService: NetworkServiceProtocol
    
    public init(networkService: NetworkServiceProtocol = URLSessionNetworkService()) {
        self.networkService = networkService
    }
    
    public func fetchProducts() async throws -> [Product] {
        let endpoint = ProductEndpoint.getProducts
        
        do {
            let response: ProductsResponseDTO = try await networkService.request(endpoint)
            return response.products.map { $0.toDomain() }
        } catch {
            // Offline fallback simulation
            return getFallbackProducts()
        }
    }
    
    public func fetchProductDetails(id: Int) async throws -> Product {
        let endpoint = ProductEndpoint.getProductDetails(id: id)
        
        do {
            let dto: ProductDTO = try await networkService.request(endpoint)
            return dto.toDomain()
        } catch {
            let fallbacks = getFallbackProducts()
            return fallbacks.first(where: { $0.id == id }) ?? fallbacks[0]
        }
    }
    
    private func getFallbackProducts() -> [Product] {
        return [
            Product(
                id: 1,
                title: "Essence Mascara Lash Princess",
                description: "The Essence Mascara Lash Princess is a popular mascara known for its volumizing effect.",
                category: "beauty",
                price: Decimal(9.99),
                rating: 4.94,
                thumbnail: "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png"
            ),
            Product(
                id: 2,
                title: "Eyeshadow Palette with Mirror",
                description: "The Eyeshadow Palette with Mirror offers a versatile selection of eyeshadow shades.",
                category: "beauty",
                price: Decimal(19.99),
                rating: 3.28,
                thumbnail: "https://cdn.dummyjson.com/products/images/beauty/Eyeshadow%20Palette%20with%20Mirror/thumbnail.png"
            ),
            Product(
                id: 3,
                title: "Powder Canister",
                description: "The Powder Canister is a finely milled setting powder for a smooth, matte finish.",
                category: "beauty",
                price: Decimal(14.99),
                rating: 3.82,
                thumbnail: "https://cdn.dummyjson.com/products/images/beauty/Powder%20Canister/thumbnail.png"
            )
        ]
    }
}
