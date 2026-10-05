import SwiftUI

public struct CheckoutInputView: View {
    @ObservedObject var viewModel: CheckoutInputViewModel
    
    public init(viewModel: CheckoutInputViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Form {
            Section(header: Text("Live Remote API Data Demo")) {
                Button(action: {
                    Task {
                        await viewModel.fetchDummyCart(id: 1)
                    }
                }) {
                    HStack {
                        if viewModel.isLoadingCart {
                            ProgressView()
                                .padding(.trailing, 8)
                        } else {
                            Image(systemName: "cart.fill.badge.plus")
                                .foregroundColor(.blue)
                        }
                        Text(viewModel.isLoadingCart ? "Loading DummyJSON Cart..." : "Fetch Sample Cart (dummyjson.com/carts/1)")
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
                .disabled(viewModel.isLoadingCart)
            }
            
            Section(header: Text("Or Create Custom Item")) {
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
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            
            Section {
                Button(action: {
                    viewModel.proceedToDiscount()
                }) {
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
}
