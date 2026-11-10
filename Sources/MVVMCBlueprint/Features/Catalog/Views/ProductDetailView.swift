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
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(height: 220)
                }
                .frame(maxWidth: .infinity)
                .clipShape(.rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.title)
                        .font(.title2)
                        .bold()

                    HStack {
                        Text("Category: \(product.category.capitalized)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Label {
                            Text(product.rating, format: .number.precision(.fractionLength(1)))
                                .bold()
                        } icon: {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }

                    Text(product.price, format: .currency(code: "USD"))
                        .font(.title)
                        .bold()
                        .foregroundStyle(.green)
                        .padding(.top, 4)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(product.description)
                        .foregroundStyle(.secondary)
                }

                Button("Add to Cart & Checkout", systemImage: "cart.fill.badge.plus", action: proceedToCheckout)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("Product Details")
    }

    private func proceedToCheckout() {
        coordinator?.proceedToCheckout(with: product)
    }
}
