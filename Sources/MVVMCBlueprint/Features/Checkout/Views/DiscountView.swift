import SwiftUI

public struct DiscountView: View {
    @ObservedObject var viewModel: DiscountViewModel
    
    public init(viewModel: DiscountViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Order Summary (\(viewModel.order.items.count) Items)")
                    .font(.headline)
                
                ForEach(viewModel.order.items) { item in
                    HStack {
                        Text("\(item.name) (x\(item.quantity))")
                            .font(.subheadline)
                        Spacer()
                        Text("$\(NSDecimalNumber(decimal: item.price * Decimal(item.quantity)).stringValue)")
                            .font(.subheadline)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Subtotal:")
                        .bold()
                    Spacer()
                    Text("$\(NSDecimalNumber(decimal: viewModel.order.subtotal).stringValue)")
                        .bold()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            VStack(spacing: 12) {
                Text("Try promo codes: SAVE10, SAVE20, VIP50")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("Enter Promo Code", text: $viewModel.promoCodeInput)
                        .textFieldStyle(.roundedBorder)
#if os(iOS)
                        .textInputAutocapitalization(.characters)
#endif
                    
                    Button("Apply") {
                        viewModel.applyPromoCode()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if let discount = viewModel.appliedDiscount {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Applied \(discount.code) (\(NSDecimalNumber(decimal: discount.percentage * 100).stringValue)% OFF)")
                            .foregroundColor(.green)
                            .bold()
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.skipOrProceedToPayment()
            }) {
                Text(viewModel.appliedDiscount != nil ? "Proceed to Payment" : "Skip Discount & Pay")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Discounts")
    }
}
