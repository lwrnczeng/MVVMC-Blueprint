import Foundation

/// Repository Protocol owned by the Domain Layer for Catalog management.
public protocol ProductRepositoryProtocol: Sendable {
    func fetchProducts() async throws -> [Product]
    func fetchProductDetails(id: Int) async throws -> Product
}
