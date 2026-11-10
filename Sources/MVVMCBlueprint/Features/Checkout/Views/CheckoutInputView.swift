import SwiftUI

public struct CheckoutInputView: View {
    @Bindable private var viewModel: CheckoutInputViewModel
    
    public init(viewModel: CheckoutInputViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Form {
            Section("Live Remote API Data Demo") {
                Button(action: fetchCart) {
                    HStack {
                        if viewModel.isLoadingCart {
                            ProgressView()
                                .padding(.trailing, 8)
                        } else {
                            Image(systemName: "cart.fill.badge.plus")
                                .foregroundStyle(.blue)
                        }
                        Text(viewModel.isLoadingCart ? "Loading DummyJSON Cart..." : "Fetch Sample Cart (dummyjson.com/carts/1)")
                            .bold()
                            .foregroundStyle(.blue)
                    }
                }
                .disabled(viewModel.isLoadingCart)
            }
            
            Section("Or Create Custom Item") {
                TextField("Item Name (e.g. Swift Architecture Book)", text: $viewModel.itemName)
                
                TextField("Price per item (USD)", text: $viewModel.itemPriceText)
#if os(iOS)
                    .keyboardType(.decimalPad)
#endif
                
                Stepper("Quantity: \(viewModel.quantity)", value: $viewModel.quantity, in: 1...99)
            }
            
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            
            Section {
                Button(action: continueToDiscount) {
                    HStack {
                        Spacer()
                        Text("Continue to Discount")
                            .bold()
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Checkout")
    }

    private func fetchCart() {
        Task {
            await viewModel.fetchDummyCart(id: 1)
        }
    }

    private func continueToDiscount() {
        viewModel.proceedToDiscount()
    }
}
