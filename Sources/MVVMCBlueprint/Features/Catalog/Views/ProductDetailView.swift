import SwiftUI

public struct ProductDetailView: View {
    public let product: Product
    private weak var coordinator: CatalogCoordinatorProtocol?
    
    public init(product: Product, coordinator: CatalogCoordinatorProtocol?) {
        self.product = product
        self.coordinator = coordinator
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: product.thumbnail)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 220)
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.title)
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        Text("Category: \(product.category.capitalized)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", product.rating))
                                .bold()
                        }
                    }
                    
                    Text("$\(String(format: "%.2f", NSDecimalNumber(decimal: product.price).doubleValue))")
                        .font(.title)
                        .bold()
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 30)
                
                Button(action: {
                    coordinator?.proceedToCheckout(with: product)
                }) {
                    HStack {
                        Image(systemName: "cart.fill.badge.plus")
                        Text("Add to Cart & Checkout")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Product Details")
    }
}
