import Foundation

/// Navigation routes enum for Catalog feature.
public enum CatalogRoute: Hashable, Sendable {
    case productList
    case productDetail(Product)
}
