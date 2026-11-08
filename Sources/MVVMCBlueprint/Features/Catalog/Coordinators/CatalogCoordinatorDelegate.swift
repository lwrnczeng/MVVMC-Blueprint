import Foundation

/// Cross-Feature Protocol Contract for Catalog Feature.
/// Decouples CatalogFeature from CheckoutFeature (Dependency Inversion / Modular Boundaries).
@MainActor
public protocol CatalogCoordinatorDelegate: AnyObject {
    /// Triggered when a user selects a product in the catalog and wants to proceed to checkout.
    func catalogDidSelectProductForCheckout(_ product: Product)
}
