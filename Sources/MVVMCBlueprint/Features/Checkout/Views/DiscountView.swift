import SwiftUI

public struct DiscountView: View {
    @Bindable private var viewModel: DiscountViewModel
    
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
                        Text(item.price * Decimal(item.quantity), format: .currency(code: "USD"))
                            .font(.subheadline)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Subtotal:")
                        .bold()
                    Spacer()
                    Text(viewModel.order.subtotal, format: .currency(code: "USD"))
                        .bold()
                }
            }
            .padding()
            .background(.quaternary, in: .rect(cornerRadius: 10))
            
            VStack(spacing: 12) {
                Text("Try promo codes: SAVE10, SAVE20, VIP50")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    TextField("Enter Promo Code", text: $viewModel.promoCodeInput)
                        .textFieldStyle(.roundedBorder)
#if os(iOS)
                        .textInputAutocapitalization(.characters)
#endif
                    
                    Button("Apply", action: applyPromoCode)
                        .buttonStyle(.borderedProminent)
                }
                
                if let discount = viewModel.appliedDiscount {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Applied \(discount.code) (\(discount.percentage.formatted(.percent)) OFF)")
                            .foregroundStyle(.green)
                            .bold()
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Button(
                viewModel.appliedDiscount != nil ? "Proceed to Payment" : "Skip Discount & Pay",
                action: proceed
            )
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .navigationTitle("Discounts")
    }

    private func applyPromoCode() {
        viewModel.applyPromoCode()
    }

    private func proceed() {
        viewModel.skipOrProceedToPayment()
    }
}
