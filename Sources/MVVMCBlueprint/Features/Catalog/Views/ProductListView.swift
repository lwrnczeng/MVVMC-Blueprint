import SwiftUI

public struct ProductListView: View {
    @ObservedObject var viewModel: CatalogViewModel
    
    public init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading Products from DummyJSON...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task { await viewModel.loadProducts() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List(viewModel.products) { product in
                    Button(action: {
                        viewModel.selectProduct(product)
                    }) {
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: product.thumbnail)) { image in
                                image.resizable().aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("$\(String(format: "%.2f", NSDecimalNumber(decimal: product.price).doubleValue))")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.green)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text(String(format: "%.1f", product.rating))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
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
}
