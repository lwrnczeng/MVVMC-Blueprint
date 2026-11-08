import Foundation

public protocol FetchProductsUseCaseProtocol: Sendable {
    func execute() async throws -> [Product]
}

/// Use Case encapsulating business rules for fetching catalog products.
public struct FetchProductsUseCase: FetchProductsUseCaseProtocol {
    private let repository: ProductRepositoryProtocol
    
    public init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> [Product] {
        let products = try await repository.fetchProducts()
        // Example domain rule: Sort products by rating descending
        return products.sorted(by: { $0.rating > $1.rating })
    }
}
