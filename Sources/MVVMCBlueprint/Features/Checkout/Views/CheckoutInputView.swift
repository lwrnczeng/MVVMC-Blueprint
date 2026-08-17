import SwiftUI

public struct CheckoutInputView: View {
    @ObservedObject var viewModel: CheckoutInputViewModel
    
    public init(viewModel: CheckoutInputViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Form {
            Section(header: Text("New Order Details")) {
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
