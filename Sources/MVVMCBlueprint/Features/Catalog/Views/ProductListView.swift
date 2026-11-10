import SwiftUI

public struct ProductListView: View {
    private let viewModel: CatalogViewModel

    public init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading products")
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Unable to Load Products", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Retry", action: retryLoading)
                        .buttonStyle(.borderedProminent)
                }
            } else if viewModel.products.isEmpty {
                ContentUnavailableView(
                    "No Products Available",
                    systemImage: "shippingbox",
                    description: Text("Try reloading the catalog later.")
                )
            } else {
                List(viewModel.products) { product in
                    Button {
                        viewModel.selectProduct(product)
                    } label: {
                        ProductRowView(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Product Catalog")
        .task {
            if viewModel.products.isEmpty {
                await viewModel.loadProducts()
            }
        }
    }

    private func retryLoading() {
        Task {
            await viewModel.loadProducts()
        }
    }
}
