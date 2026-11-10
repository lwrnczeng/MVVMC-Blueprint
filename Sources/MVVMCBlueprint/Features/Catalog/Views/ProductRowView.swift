import SwiftUI

/// Reusable row view displaying product summary in catalog list.
public struct ProductRowView: View {
    public let product: Product

    public init(product: Product) {
        self.product = product
    }

    public var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: product.thumbnail)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .frame(width: 50, height: 50)
            .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)

                HStack {
                    Text(product.price, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.green)

                    Spacer()

                    Label {
                        Text(product.rating, format: .number.precision(.fractionLength(1)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                    .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.title), price \(product.price.formatted(.currency(code: "USD"))), rating \(product.rating.formatted(.number.precision(.fractionLength(1)))) stars")
    }
}
