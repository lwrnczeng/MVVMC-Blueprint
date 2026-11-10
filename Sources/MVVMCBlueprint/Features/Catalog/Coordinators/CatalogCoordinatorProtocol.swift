import Foundation

/// Protocol defining navigation actions that ViewModels or views can request from the CatalogCoordinator.
@MainActor
public protocol CatalogCoordinatorProtocol: AnyObject {
    func showProductDetail(_ product: Product)
    func proceedToCheckout(with product: Product)
}
